class Question < ActiveRecord::Base
  include Elasticsearch::Model

  has_many :answers
  has_one :accepted_answer, class_name: Answer
  belongs_to :owner, class_name: User
  belongs_to :last_editor, class_name: User
  has_many :comments, as: :commentable, inverse_of: :commentable

  index_name [Rails.application.engine_name, Rails.env].join('-')

  mapping do
    indexes :title, type: 'string'
    indexes :body, type: 'string', analyzer: 'html_strip' # Custom analyzer, see index_manager.rb
    indexes :tags, type: 'string', analyzer: 'keyword'

    indexes :answer_count, type: 'long'
    indexes :comment_count, type: 'long'
    indexes :favorite_count, type: 'long'
    indexes :view_count, type: 'long'
    indexes :has_accepted_answer, type: 'boolean'
    indexes :rating, type: 'long'

    indexes :creation_date, type: 'date'

    indexes :last_activity_date, type: 'date'
    indexes :last_edit_date, type: 'date'
    indexes :last_editor do
      indexes :display_name, type: 'string' do
        indexes :raw, analyzer: 'keyword'
      end
      indexes :url, type: 'string', analyzer: 'keyword'
    end

    indexes :owner do
      indexes :display_name, type: 'string' do
        indexes :raw, analyzer: 'keyword'
      end
      indexes :url, type: 'string', analyzer: 'keyword'
    end

    indexes :comments, type: 'nested' do
      indexes :creation_date, type: 'date'
      indexes :owner do
        indexes :display_name, type: 'string' do
          indexes :raw, type: 'string', analyzer: 'keyword'
        end
        indexes :url, type: 'string', analyzer: 'keyword'
      end
      indexes :rating, type: 'long'
      indexes :text, type: 'string'
    end
  end

  def as_indexed_json(options={})
    self.as_json(
      only:    [ :title, :body, :rating, :answer_count, :comment_count, :favorite_count, :view_count, :popularity, :creation_date, :last_activity_date, :last_edit_date, :last_editor ],
      include: { owner:      { only: [:display_name, :url] },
                 comments:   { only: [:text, :rating, :creation_date], include: { owner: { only: [:display_name, :url] } } }
               }
    ).merge(
      tags: tags.split(/<([^<]+)>/).reject { |s| s.blank? },
      has_accepted_answer: self.accepted_answer_id.present?
    )
  end
end
