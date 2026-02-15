require 'rails_helper'

RSpec.describe User, type: :model do
  # 正常系
  describe "バリデーション" do
    context "有効な場合" do
      it "メールアドレスとパスワードがあれば有効である" do
        user = User.new(
          email: "test@example.com",
          password: "password123"
        )
        expect(user).to be_valid
      end
    end

    context "メールアドレスが無効な場合" do
      it "メールアドレスがなければ無効である" do
        user = User.new(
          email: nil,
          password: "password123"
        )
        expect(user).to be_invalid
      end

      it "メールアドレスが重複している場合は無効である" do
        User.create!(
          email: "test@example.com",
          password: "password123"
        )
        user = User.new(
          email: "test@example.com",
          password: "password123"
        )
        expect(user).to be_invalid
      end
    end

    context "パスワードが無効な場合" do
      it "パスワードがなければ無効である" do
        user = User.new(
          email: "test@example.com",
          password: nil
        )
        expect(user).to be_invalid
      end

      it "パスワードが6文字未満の場合は無効である" do
        user = User.new(
          email: "test@example.com",
          password: "pass"
        )
        expect(user).to be_invalid
      end
    end
  end

  # アソシエーション
  describe "アソシエーション" do
    it "複数のbrainstormを持つことができる" do
      association = User.reflect_on_association(:brainstorms)
      expect(association.macro).to eq :has_many
    end

    it "ユーザーを削除するとbrainstormも削除される" do
      user = User.create!(
        email: "test@example.com",
        password: "password123"
      )
      user.brainstorms.create!(title: "テストブレスト")
      expect { user.destroy }.to change(Brainstorm, :count).by(-1)
    end
  end
end
