class BrainstormInvitation < ApplicationRecord
  belongs_to :brainstorm

  ROLES = %w[editor viewer].freeze

  validates :role, inclusion: { in: ROLES }
  validates :role, uniqueness: { scope: :brainstorm_id }
  validates :token, presence: true, uniqueness: true

  before_validation :generate_token, on: :create

  private

  def generate_token
    self.token ||= SecureRandom.urlsafe_base64(16)
  end
end
