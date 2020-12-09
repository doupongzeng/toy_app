class Relationship < ApplicationRecord
  #others follow me
  belongs_to :follower, class_name: "User"
  #I follow others
  belongs_to :followed, class_name: "User"
  validates :follower_id, presence: true
  validates :followed_id, presence: true
end
