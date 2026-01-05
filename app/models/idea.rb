class Idea < ApplicationRecord
  # Associations
  belongs_to :brainstorm
  has_many :idea_groups, dependent: :destroy
  has_many :groups, through: :idea_groups

  # Validations
  validates :content, presence: true
  validates :source, presence: true, inclusion: { in: %w[ai user] }

end
