class Brainstorm < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :ideas, dependent: :destroy
  has_many :groups, dependent: :destroy

  # Validations
  validates :title, presence: true, length: { maximum: 100 }
  validates :description, length: { maximum: 500 }, allow_blank: true
end
