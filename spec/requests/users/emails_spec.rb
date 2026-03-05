require 'rails_helper'

RSpec.describe "Users::Emails", type: :request do
  let!(:user) { create(:user) }
  let!(:sns_user) { create(:user, provider: "google_oauth2", uid: "123456") }

  describe "GET /users/email/edit" do
    context "ログインしている場合" do
      before { sign_in user }

      it "設定ページにリダイレクトされる" do  # 200ではなくリダイレクトに変更
        get edit_users_email_path
        expect(response).to redirect_to(edit_users_profile_path)
      end
    end

    context "ログインしていない場合" do
      it "ログインページにリダイレクトされる" do
        get edit_users_email_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "SNSユーザーの場合" do
      before { sign_in sns_user }

      it "設定ページにリダイレクトされる" do
        get edit_users_email_path
        expect(response).to redirect_to(edit_users_profile_path)
      end
    end
  end

  describe "PATCH /users/email" do
    before { sign_in user }

    context "有効なパラメータの場合" do
      it "未確認メールアドレスが更新される" do
        patch users_email_path, params: {
          user: {
            email: "new@example.com",
            current_password: "password123"
          }
        }
        expect(user.reload.unconfirmed_email).to eq("new@example.com")
      end

      it "設定ページにリダイレクトされる" do
        patch users_email_path, params: {
          user: {
            email: "new@example.com",
            current_password: "password123"
          }
        }
        expect(response).to redirect_to(edit_users_profile_path)
      end
    end

    context "無効なパラメータの場合" do
      it "パスワードが間違っている場合は更新されない" do
        patch users_email_path, params: {
          user: {
            email: "new@example.com",
            current_password: "wrongpassword"
          }
        }
        expect(user.reload.unconfirmed_email).not_to eq("new@example.com")
        expect(response).to redirect_to(edit_users_profile_path)  # renderではなくredirect
      end
    end
  end
end
