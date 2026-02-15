require 'rails_helper'

RSpec.describe Idea, type: :model do
  describe "バリデーション" do
    context "有効な場合" do
      it "contentとsourceがあれば有効である" do
        user = User.create!(email: "test@example.com", password: "password123")
        brainstorm = user.brainstorms.create!(title: "テストブレスト")
        idea = Idea.new(
          content: "テストアイデア",
          source: "user",
          brainstorm: brainstorm
        )
        expect(idea).to be_valid
      end

      it "sourceがaiでも有効である" do
        user = User.create!(email: "test@example.com", password: "password123")
        brainstorm = user.brainstorms.create!(title: "テストブレスト")
        idea = Idea.new(
          content: "テストアイデア",
          source: "ai",
          brainstorm: brainstorm
        )
        expect(idea).to be_valid
      end
    end

    context "contentが無効な場合" do
      it "contentがなければ無効である" do
        idea = Idea.new(content: nil, source: "user")
        expect(idea).to be_invalid
      end

      it "contentが500文字を超える場合は無効である" do
        idea = Idea.new(content: "a" * 501, source: "user")
        expect(idea).to be_invalid
      end

      it "contentが500文字以内であれば有効である" do
        user = User.create!(email: "test@example.com", password: "password123")
        brainstorm = user.brainstorms.create!(title: "テストブレスト")
        idea = Idea.new(
          content: "a" * 500,
          source: "user",
          brainstorm: brainstorm
        )
        expect(idea).to be_valid
      end
    end

    context "sourceが無効な場合" do
      it "sourceがなければ無効である" do
        idea = Idea.new(content: "テストアイデア", source: nil)
        expect(idea).to be_invalid
      end

      it "sourceがai/user以外の場合は無効である" do
        idea = Idea.new(content: "テストアイデア", source: "invalid")
        expect(idea).to be_invalid
      end
    end
  end

  describe "アソシエーション" do
    it "Brainstormに紐づいている" do
      association = Idea.reflect_on_association(:brainstorm)
      expect(association.macro).to eq :belongs_to
    end

    it "複数のidea_groupsを持つことができる" do
      association = Idea.reflect_on_association(:idea_groups)
      expect(association.macro).to eq :has_many
    end

    it "idea_groupsを通じてgroupsに紐づいている" do
      association = Idea.reflect_on_association(:groups)
      expect(association.macro).to eq :has_many
      expect(association.options[:through]).to eq :idea_groups
    end

    it "ideaを削除するとidea_groupsも削除される" do
      user = User.create!(email: "test@example.com", password: "password123")
      brainstorm = user.brainstorms.create!(title: "テストブレスト")
      idea = brainstorm.ideas.create!(content: "テストアイデア", source: "user")
      group = brainstorm.groups.create!(name: "テストグループ")
      IdeaGroup.create!(idea: idea, group: group)
      expect { idea.destroy }.to change(IdeaGroup, :count).by(-1)
    end
  end
end
