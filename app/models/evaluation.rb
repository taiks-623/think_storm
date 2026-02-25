class Evaluation < ApplicationRecord
  belongs_to :idea
  belongs_to :evaluation_axis, class_name: "EvaluationAxis", foreign_key: "evaluation_axis_id"

  validates :score, presence: true,
                    numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
  validates :idea_id, uniqueness: { scope: :evaluation_axis_id }
end
