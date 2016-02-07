class Question < ActiveRecord::Base
  has_many :answers
  has_one :accepted_answer, class_name: Answer
  belongs_to :owner, class_name: User
  belongs_to :last_editor, class_name: User
  has_many :comments, as: :commentable, inverse_of: :commentable
end
