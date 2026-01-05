class IdeaGroup < ApplicationRecord
  # Associations
  belongs_to :idea
  belongs_to :group

  # Validations
  validates :idea_id, uniqueness: { scope: :group_id }
end
