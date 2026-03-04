class Vote < ApplicationRecord
  belongs_to :idea
  belongs_to :user

  validates :user_id, uniqueness: { scope: :idea_id, message: "すでに投票済みです" }
end
