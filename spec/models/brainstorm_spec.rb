require 'rails_helper'

RSpec.describe Brainstorm, type: :model do
  # 正常系
  describe "バリデーション" do
    context "有効な場合" do
      it "タイトルがあれば有効である" do
        user = User.create!(
          email: "test@example.com",
          password: "password123"
        )
        brainstorm = Brainstorm.new(
          title: "テストブレスト",
          user: user
        )
        expect(brainstorm).to be_valid
      end

      it "descriptionがなくても有効である" do
        user = User.create!(
          email: "test@example.com",
          password: "password123"
        )
        brainstorm = Brainstorm.new(
          title: "テストブレスト",
          description: nil,
          user: user
        )
        expect(brainstorm).to be_valid
      end
    end

    context "titleが無効な場合" do
      it "titleがなければ無効である" do
        brainstorm = Brainstorm.new(title: nil)
        expect(brainstorm).to be_invalid
      end

      it "titleが100文字を超える場合は無効である" do
        brainstorm = Brainstorm.new(title: "a" * 101)
        expect(brainstorm).to be_invalid
      end

      it "titleが100文字以内であれば有効である" do
        user = User.create!(
          email: "test@example.com",
          password: "password123"
        )
        brainstorm = Brainstorm.new(
          title: "a" * 100,
          user: user
        )
        expect(brainstorm).to be_valid
      end
    end

    context "descriptionが無効な場合" do
      it "descriptionが500文字を超える場合は無効である" do
        brainstorm = Brainstorm.new(
          title: "テストブレスト",
          description: "a" * 501
        )
        expect(brainstorm).to be_invalid
      end

      it "descriptionが500文字以内であれば有効である" do
        user = User.create!(
          email: "test@example.com",
          password: "password123"
        )
        brainstorm = Brainstorm.new(
          title: "テストブレスト",
          description: "a" * 500,
          user: user
        )
        expect(brainstorm).to be_valid
      end
    end
  end

  # アソシエーション
  describe "アソシエーション" do
    it "Userに紐づいている" do
      association = Brainstorm.reflect_on_association(:user)
      expect(association.macro).to eq :belongs_to
    end

    it "複数のideasを持つことができる" do
      association = Brainstorm.reflect_on_association(:ideas)
      expect(association.macro).to eq :has_many
    end

    it "複数のgroupsを持つことができる" do
      association = Brainstorm.reflect_on_association(:groups)
      expect(association.macro).to eq :has_many
    end

    it "brainstormを削除するとideasも削除される" do
      user = User.create!(
        email: "test@example.com",
        password: "password123"
      )
      brainstorm = user.brainstorms.create!(title: "テストブレスト")
      brainstorm.ideas.create!(content: "テストアイデア", source: "user")
      expect { brainstorm.destroy }.to change(Idea, :count).by(-1)
    end

    it "brainstormを削除するとgroupsも削除される" do
      user = User.create!(
        email: "test@example.com",
        password: "password123"
      )
      brainstorm = user.brainstorms.create!(title: "テストブレスト")
      brainstorm.groups.create!(name: "テストグループ")
      expect { brainstorm.destroy }.to change(Group, :count).by(-1)
    end
  end
end
