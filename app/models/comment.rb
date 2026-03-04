class Comment < ApplicationRecord
  belongs_to :idea
  belongs_to :user

  validates :content, presence: true
end
