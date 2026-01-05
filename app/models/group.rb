class Group < ApplicationRecord
  # Associations
  belongs_to :brainstorm
  has_many :idea_groups, dependent: :destroy
  has_many :ideas, through: :idea_groups

  # Validations
  validates :name, presence: true
end
