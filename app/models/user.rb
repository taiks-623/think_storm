class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable,
         :omniauthable, omniauth_providers: [ :google_oauth2, :line ]

  has_many :brainstorms, dependent: :destroy
  has_many :brainstorm_members, dependent: :destroy
  has_many :shared_brainstorms, through: :brainstorm_members, source: :brainstorm
  has_many :votes, dependent: :destroy
  has_many :comments, dependent: :destroy

  validates :name, length: { maximum: 50 }, allow_blank: true

  def self.from_omniauth(auth)
    user = where(provider: auth.provider, uid: auth.uid).first_or_create do |u|
      u.email = auth.info.email.presence || "#{auth.uid}@line.thinkstorm.jp"
      u.password = Devise.friendly_token[0, 20]
      u.skip_confirmation!
    end
    user.skip_confirmation! if user.confirmed_at.nil?
    user.save if user.confirmed_at_changed?
    user
  end
end
