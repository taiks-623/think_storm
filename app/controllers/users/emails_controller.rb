class Users::EmailsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_password_authentication

  def edit
    redirect_to edit_users_profile_path
  end

  def update
    if current_user.update_with_password(email_params)
      redirect_to edit_users_profile_path,
                  notice: "確認メールを送信しました。メールのリンクをクリックして変更を完了してください"
    else
      redirect_to edit_users_profile_path,
                  alert: current_user.errors.full_messages.first
    end
  end

  private

  def email_params
    params.require(:user).permit(:email, :current_password)
  end

  def require_password_authentication
    if current_user.provider.present?
      redirect_to edit_users_profile_path, alert: "この機能はメールアドレスで登録したユーザーのみ利用できます"
    end
  end
end
