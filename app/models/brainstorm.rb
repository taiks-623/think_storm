class Brainstorm < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :ideas, dependent: :destroy
  has_many :groups, dependent: :destroy

  # Validations
  validates :title, presence: true
end
