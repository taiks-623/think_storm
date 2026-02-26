# app/models/brainstorm_member.rb
class BrainstormMember < ApplicationRecord
  belongs_to :brainstorm
  belongs_to :user

  ROLES = %w[owner editor viewer].freeze

  validates :role, inclusion: { in: ROLES }
  validates :user_id, uniqueness: { scope: :brainstorm_id }
end
