class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable,
         :omniauthable, omniauth_providers: [ :google_oauth2, :line ]

  has_many :brainstorms, dependent: :destroy

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
