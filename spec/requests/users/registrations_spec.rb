require 'rails_helper'

RSpec.describe "Users::Registrations", type: :request do
  describe "POST /users" do
    context "有効なパラメータの場合" do
      it "ユーザーが作成されてダッシュボードにリダイレクトされる" do
        expect {
          post user_registration_path, params: {
            user: {
              email: "newuser@example.com",
              password: "password123",
              password_confirmation: "password123"
            }
          }
        }.to change(User, :count).by(1)
        expect(response).to redirect_to(dashboard_path)
      end
    end

    context "無効なパラメータの場合" do
      it "パスワードが一致しない場合はユーザーが作成されない" do
        expect {
          post user_registration_path, params: {
            user: {
              email: "newuser@example.com",
              password: "password123",
              password_confirmation: "wrongpassword"
            }
          }
        }.not_to change(User, :count)
      end

      it "メールアドレスが重複している場合はユーザーが作成されない" do
        create(:user, email: "duplicate@example.com")
        expect {
          post user_registration_path, params: {
            user: {
              email: "duplicate@example.com",
              password: "password123",
              password_confirmation: "password123"
            }
          }
        }.not_to change(User, :count)
      end
    end
  end
end
