require 'rails_helper'

RSpec.describe "Users::Accounts", type: :request do
  let!(:user) { create(:user) }

  describe "GET /users/account" do
    context "ログインしている場合" do
      before { sign_in user }

      it "設定ページにリダイレクトされる" do
        get users_account_path
        expect(response).to redirect_to(edit_users_profile_path)
      end
    end

    context "ログインしていない場合" do
      it "ログインページにリダイレクトされる" do
        get users_account_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "DELETE /users/account" do
    before { sign_in user }

    it "アカウントが削除される" do
      expect {
        delete users_account_path
      }.to change(User, :count).by(-1)
    end

    it "トップページにリダイレクトされる" do
      delete users_account_path
      expect(response).to redirect_to(root_path)
    end
  end
end
