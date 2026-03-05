class Users::AccountsController < ApplicationController
  before_action :authenticate_user!

  def show
    redirect_to edit_users_profile_path
  end

  def destroy
    current_user.destroy
    redirect_to root_path, notice: "アカウントを削除しました"
  end
end
