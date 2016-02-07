class Comment < ActiveRecord::Base
  belongs_to :owner, class_name: User
  belongs_to :commentable, polymorphic: true, inverse_of: :comments
end
