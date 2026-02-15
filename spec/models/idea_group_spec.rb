require 'rails_helper'

RSpec.describe IdeaGroup, type: :model do
  describe "バリデーション" do
    context "有効な場合" do
      it "ideaとgroupがあれば有効である" do
        user = User.create!(email: "test@example.com", password: "password123")
        brainstorm = user.brainstorms.create!(title: "テストブレスト")
        idea = brainstorm.ideas.create!(content: "テストアイデア", source: "user")
        group = brainstorm.groups.create!(name: "テストグループ")
        idea_group = IdeaGroup.new(idea: idea, group: group)
        expect(idea_group).to be_valid
      end
    end

    context "無効な場合" do
      it "同じideaとgroupの組み合わせは無効である" do
        user = User.create!(email: "test@example.com", password: "password123")
        brainstorm = user.brainstorms.create!(title: "テストブレスト")
        idea = brainstorm.ideas.create!(content: "テストアイデア", source: "user")
        group = brainstorm.groups.create!(name: "テストグループ")
        IdeaGroup.create!(idea: idea, group: group)
        duplicate = IdeaGroup.new(idea: idea, group: group)
        expect(duplicate).to be_invalid
      end
    end
  end

  describe "アソシエーション" do
    it "Ideaに紐づいている" do
      association = IdeaGroup.reflect_on_association(:idea)
      expect(association.macro).to eq :belongs_to
    end

    it "Groupに紐づいている" do
      association = IdeaGroup.reflect_on_association(:group)
      expect(association.macro).to eq :belongs_to
    end
  end
end
