class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable,
         :omniauthable, omniauth_providers: [ :google_oauth2, :line ]

  has_many :brainstorms, dependent: :destroy

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email.presence || "#{auth.uid}@line.thinkstorm.jp"
      user.password = Devise.friendly_token[0, 20]  # ランダムパスワードを自動生成
      user.skip_confirmation!
    end
  end
end
