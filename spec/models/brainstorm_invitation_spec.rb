require 'rails_helper'

RSpec.describe BrainstormInvitation, type: :model do
  describe "バリデーション" do
    it "editor roleは有効である" do
      invitation = build(:brainstorm_invitation, role: "editor")
      expect(invitation).to be_valid
    end

    it "viewer roleは有効である" do
      invitation = build(:brainstorm_invitation, role: "viewer")
      expect(invitation).to be_valid
    end

    it "無効なroleは無効である" do
      invitation = build(:brainstorm_invitation, role: "owner")
      expect(invitation).to be_invalid
    end

    it "同じブレストに同じroleのinvitationは作れない" do
      invitation = create(:brainstorm_invitation, role: "editor")
      duplicate = build(:brainstorm_invitation, brainstorm: invitation.brainstorm, role: "editor")
      expect(duplicate).to be_invalid
    end

    it "tokenが自動生成される" do
      invitation = create(:brainstorm_invitation)
      expect(invitation.token).to be_present
    end
  end

  describe "アソシエーション" do
    it "Brainstormに紐づいている" do
      expect(BrainstormInvitation.reflect_on_association(:brainstorm).macro).to eq :belongs_to
    end
  end
end
