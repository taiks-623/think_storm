class Message < ApplicationRecord
  belongs_to :conversation
  has_many :evaluations, dependent: :destroy

  validates :role, presence: true, inclusion: { in: %w[user assistant] }
  validates :content, presence: true
end
