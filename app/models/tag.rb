class Tag < ApplicationRecord
  belongs_to :brainstorm
  has_many :idea_tags, dependent: :destroy
  has_many :ideas, through: :idea_tags

  validates :name, presence: true
  validates :name, uniqueness: { scope: :brainstorm_id }
end
