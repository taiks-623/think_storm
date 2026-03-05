require 'rails_helper'

RSpec.describe Vote, type: :model do
  describe "バリデーション" do
    it "有効なvoteは有効である" do
      vote = build(:vote)
      expect(vote).to be_valid
    end

    it "同じユーザーが同じアイデアに2重投票できない" do
      vote = create(:vote)
      duplicate = build(:vote, idea: vote.idea, user: vote.user)
      expect(duplicate).to be_invalid
    end
  end

  describe "アソシエーション" do
    it "Ideaに紐づいている" do
      expect(Vote.reflect_on_association(:idea).macro).to eq :belongs_to
    end

    it "Userに紐づいている" do
      expect(Vote.reflect_on_association(:user).macro).to eq :belongs_to
    end
  end
end
