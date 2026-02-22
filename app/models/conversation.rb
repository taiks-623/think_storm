class Conversation < ApplicationRecord
  belongs_to :brainstorm
  belongs_to :idea

  has_many :messages, dependent: :destroy

  validates :brainstorm_id, presence: true
  validates :idea_id, presence: true
end
