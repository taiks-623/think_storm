require 'rails_helper'

RSpec.describe "Profiles", type: :request do
  let(:user) { create(:user) }

  describe "GET /profile" do
    context "ログイン済みの場合" do
      before { sign_in user }

      it "正常にレスポンスが返る" do
        get profile_path
        expect(response).to have_http_status(200)
      end
    end

    context "未ログインの場合" do
      it "ログインページにリダイレクトされる" do
        get profile_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET /profile/edit" do
    context "ログイン済みの場合" do
      before { sign_in user }

      it "正常にレスポンスが返る" do
        get edit_profile_path
        expect(response).to have_http_status(200)
      end
    end

    context "未ログインの場合" do
      it "ログインページにリダイレクトされる" do
        get edit_profile_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "PATCH /profile" do
    context "ログイン済みの場合" do
      before { sign_in user }

      it "メールアドレスが更新されてプロフィールページにリダイレクトされる" do
        patch profile_path, params: {
          user: {
            email: "new@example.com",
            current_password: "password123"
          }
        }
        expect(response).to redirect_to(profile_path)
      end

      it "現在のパスワードが間違っている場合は更新されない" do
        patch profile_path, params: {
          user: {
            email: "new@example.com",
            current_password: "wrongpassword"
          }
        }
        expect(response).to have_http_status(422)
      end
    end

    context "未ログインの場合" do
      it "ログインページにリダイレクトされる" do
        patch profile_path, params: { user: { email: "new@example.com" } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "DELETE /profile/cancel" do
    context "ログイン済みの場合" do
      before { sign_in user }

      it "アカウントが削除されてトップページにリダイレクトされる" do
        expect {
          delete cancel_profile_path
        }.to change(User, :count).by(-1)
        expect(response).to redirect_to(root_path)
      end
    end

    context "未ログインの場合" do
      it "ログインページにリダイレクトされる" do
        delete cancel_profile_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
