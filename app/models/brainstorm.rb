class Brainstorm < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :ideas, dependent: :destroy
  has_many :groups, dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :conversations, dependent: :destroy
  has_many :evaluation_axes, class_name: "EvaluationAxis", dependent: :destroy
  has_many :brainstorm_members, dependent: :destroy
  has_many :members, through: :brainstorm_members, source: :user
  has_many :brainstorm_invitations, dependent: :destroy

  # Validations
  validates :title, presence: true, length: { maximum: 100 }
  validates :description, length: { maximum: 500 }, allow_blank: true

  # 権限チェク用のヘルパーメソッド
  def owner?(user)
    self.user_id == user.id
  end

  def member?(user)
    owner?(user) || brainstorm_members.exists?(user: user)
  end

  def editor?(user)
    owner?(user) || brainstorm_members.exists?(user: user, role: "editor")
  end

  def role_for(user)
    return "owner" if owner?(user)
    brainstorm_members.find_by(user: user)&.role
  end
end
