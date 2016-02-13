class Answer < ActiveRecord::Base
  include Elasticsearch::Model

  belongs_to :owner, class_name: User
  belongs_to :question
  has_many :comments, as: :commentable, inverse_of: :commentable

  index_name [Rails.application.engine_name, Rails.env].join('-')

  mapping _parent: { type: 'question' }, _routing: { required: true }  do
    indexes :body, type: 'string', analyzer: 'html_strip' # Custom analyzer, see index_manager.rb

    indexes :comment_count, type: 'long'
    indexes :popularity, type: 'long'

    indexes :creation_date, type: 'date'

    indexes :last_activity_date, type: 'date'

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
      indexes :popularity, type: 'long'
      indexes :text, type: 'string'
    end
  end

  def as_indexed_json(options={})
    self.as_json(
      only:    [ :body, :comment_count, :popularity, :creation_date, :last_activity_date ],
      include: { owner:      { only: [:display_name, :url] },
                 comments:   { only: [:text, :rating, :creation_date], include: { owner: { only: [:display_name, :url] } } }
               }
    )
  end
end
