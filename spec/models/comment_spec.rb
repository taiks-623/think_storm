require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe "バリデーション" do
    it "contentがあれば有効である" do
      comment = build(:comment)
      expect(comment).to be_valid
    end

    it "contentがなければ無効である" do
      comment = build(:comment, content: nil)
      expect(comment).to be_invalid
    end
  end

  describe "アソシエーション" do
    it "Ideaに紐づいている" do
      expect(Comment.reflect_on_association(:idea).macro).to eq :belongs_to
    end

    it "Userに紐づいている" do
      expect(Comment.reflect_on_association(:user).macro).to eq :belongs_to
    end
  end
end
