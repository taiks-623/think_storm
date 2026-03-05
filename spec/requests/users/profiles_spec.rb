require 'rails_helper'

RSpec.describe "Users::Profiles", type: :request do
  let!(:user) { create(:user) }

  describe "PATCH /users/profile" do
    before { sign_in user }

    context "有効なパラメータの場合" do
      it "名前が更新される" do
        patch users_profile_path, params: { user: { name: "新しい名前" } }
        expect(user.reload.name).to eq("新しい名前")
      end

      it "設定ページにリダイレクトされる" do
        patch users_profile_path, params: { user: { name: "新しい名前" } }
        expect(response).to redirect_to(edit_users_profile_path)
      end
    end

    context "無効なパラメータの場合" do
      it "50文字を超える名前は更新されない" do
        patch users_profile_path, params: { user: { name: "a" * 51 } }
        expect(user.reload.name).not_to eq("a" * 51)
      end
    end
  end

  describe "GET /users/profile/edit" do
    context "ログインしている場合" do
      before { sign_in user }

      it "正常にレスポンスを返す" do
        get edit_users_profile_path
        expect(response).to have_http_status(:ok)
      end
    end

    context "ログインしていない場合" do
      it "ログインページにリダイレクトされる" do
        get edit_users_profile_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
