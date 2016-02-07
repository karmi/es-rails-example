class Answer < ActiveRecord::Base
  belongs_to :owner, class_name: User
  belongs_to :question
  has_many :comments, as: :commentable, inverse_of: :commentable
end
