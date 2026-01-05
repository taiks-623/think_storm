class Idea < ApplicationRecord
  # Associations
  belongs_to :brainstorm
  has_many :idea_groups, dependent: :destroy
  has_many :groups, through: :idea_groups

  # Validations
  validates :content, presence: true, length: { maximum: 500 }
  validates :source, presence: true, inclusion: { in: %w[ai user] }

end
