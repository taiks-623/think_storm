class Idea < ApplicationRecord
  # Associations
  belongs_to :brainstorm
  belongs_to :user, optional: true
  has_many :idea_groups, dependent: :destroy
  has_many :groups, through: :idea_groups
  has_many :idea_tags, dependent: :destroy
  has_many :tags, through: :idea_tags
  has_many :conversations, dependent: :destroy
  has_many :evaluations
  has_many :votes, dependent: :destroy
  has_many :comments, dependent: :destroy

  # Validations
  validates :content, presence: true, length: { maximum: 500 }
  validates :source, presence: true, inclusion: { in: %w[ai user] }
end
