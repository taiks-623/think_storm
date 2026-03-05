require 'rails_helper'

RSpec.describe BrainstormMember, type: :model do
  describe "バリデーション" do
    it "有効なroleであれば有効である" do
      member = build(:brainstorm_member, role: "editor")
      expect(member).to be_valid
    end

    it "無効なroleは無効である" do
      member = build(:brainstorm_member, role: "invalid")
      expect(member).to be_invalid
    end

    it "同じユーザーが同じブレストに2重登録できない" do
      member = create(:brainstorm_member)
      duplicate = build(:brainstorm_member, brainstorm: member.brainstorm, user: member.user)
      expect(duplicate).to be_invalid
    end
  end

  describe "アソシエーション" do
    it "Brainstormに紐づいている" do
      expect(BrainstormMember.reflect_on_association(:brainstorm).macro).to eq :belongs_to
    end

    it "Userに紐づいている" do
      expect(BrainstormMember.reflect_on_association(:user).macro).to eq :belongs_to
    end
  end
end
