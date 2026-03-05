class Users::PasswordsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_password_authentication

  def edit; end

  def update
    if current_user.update_with_password(password_params)
      bypass_sign_in(current_user)
      redirect_to edit_users_password_path, notice: "パスワードを変更しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end

  def require_password_authentication
    if current_user.provider.present?
      redirect_to edit_users_profile_path, alert: "この機能はメールアドレスで登録したユーザーのみ利用できます"
    end
  end
end
