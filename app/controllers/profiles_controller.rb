class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
  end

  def edit
  end

  def update
    if current_user.update_with_password(profile_params)
      bypass_sign_in(current_user) # パスワード変更後もログアウトしないようにする
      redirect_to profile_path, notice: "プロフィールを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def cancel
    current_user.destroy
    redirect_to root_path, notice: "アカウントを削除しました"
  end

  private

  def profile_params
    params.require(:user).permit(:email, :password, :password_confirmation, :current_password)
  end
end
