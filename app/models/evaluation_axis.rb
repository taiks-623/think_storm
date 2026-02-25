class EvaluationAxis < ApplicationRecord
  self.table_name = "evaluation_axes"

  belongs_to :brainstorm
  has_many :evaluations, dependent: :destroy

  validates :name, presence: true
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
end
