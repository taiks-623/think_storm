require 'rails_helper'

RSpec.describe Group, type: :model do
  describe "バリデーション" do
    context "有効な場合" do
      it "nameがあれば有効である" do
        user = User.create!(email: "test@example.com", password: "password123")
        brainstorm = user.brainstorms.create!(title: "テストブレスト")
        group = Group.new(
          name: "テストグループ",
          brainstorm: brainstorm
        )
        expect(group).to be_valid
      end
    end

    context "nameが無効な場合" do
      it "nameがなければ無効である" do
        group = Group.new(name: nil)
        expect(group).to be_invalid
      end

      it "nameが50文字を超える場合は無効である" do
        group = Group.new(name: "a" * 51)
        expect(group).to be_invalid
      end

      it "nameが50文字以内であれば有効である" do
        user = User.create!(email: "test@example.com", password: "password123")
        brainstorm = user.brainstorms.create!(title: "テストブレスト")
        group = Group.new(
          name: "a" * 50,
          brainstorm: brainstorm
        )
        expect(group).to be_valid
      end
    end
  end

  describe "アソシエーション" do
    it "Brainstormに紐づいている" do
      association = Group.reflect_on_association(:brainstorm)
      expect(association.macro).to eq :belongs_to
    end

    it "複数のidea_groupsを持つことができる" do
      association = Group.reflect_on_association(:idea_groups)
      expect(association.macro).to eq :has_many
    end

    it "idea_groupsを通じてideasに紐づいている" do
      association = Group.reflect_on_association(:ideas)
      expect(association.macro).to eq :has_many
      expect(association.options[:through]).to eq :idea_groups
    end

    it "groupを削除するとidea_groupsも削除される" do
      user = User.create!(email: "test@example.com", password: "password123")
      brainstorm = user.brainstorms.create!(title: "テストブレスト")
      idea = brainstorm.ideas.create!(content: "テストアイデア", source: "user")
      group = brainstorm.groups.create!(name: "テストグループ")
      IdeaGroup.create!(idea: idea, group: group)
      expect { group.destroy }.to change(IdeaGroup, :count).by(-1)
    end
  end
end
