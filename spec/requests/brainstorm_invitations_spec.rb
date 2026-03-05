require 'rails_helper'

RSpec.describe "BrainstormInvitations", type: :request do
  let(:owner) { create(:user) }
  let(:brainstorm) { create(:brainstorm, user: owner) }
  let!(:invitation) { create(:brainstorm_invitation, brainstorm: brainstorm, role: "editor") }

  describe "GET /join/:token" do
    context "ログイン済みの場合" do
      let(:other_user) { create(:user) }
      before { login_as other_user, scope: :user }

      it "招待確認画面が表示される" do
        get join_brainstorm_path(invitation.token)
        expect(response).to have_http_status(:ok)
      end

      it "すでにメンバーの場合はブレストにリダイレクトされる" do
        brainstorm.brainstorm_members.create!(user: other_user, role: "editor")
        get join_brainstorm_path(invitation.token)
        expect(response).to redirect_to(brainstorm_path(brainstorm))
      end
    end

    context "未ログインの場合" do
      it "ログインページにリダイレクトされる" do
        get join_brainstorm_path(invitation.token)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "無効なtokenの場合" do
      before { login_as owner, scope: :user }

      it "ダッシュボードにリダイレクトされる" do
        get join_brainstorm_path("invalid_token")
        expect(response).to redirect_to(brainstorms_path)
      end
    end
  end

  describe "POST /join/:token" do
    let(:other_user) { create(:user) }
    before { login_as other_user, scope: :user }

    it "メンバーとして参加できる" do
      expect {
        post join_brainstorm_confirm_path(invitation.token)
      }.to change(BrainstormMember, :count).by(1)
      expect(response).to redirect_to(brainstorm_path(brainstorm))
    end

    it "参加後のroleはinvitationのroleと同じになる" do
      post join_brainstorm_confirm_path(invitation.token)
      member = BrainstormMember.find_by(user: other_user, brainstorm: brainstorm)
      expect(member.role).to eq("editor")
    end

    it "すでにメンバーの場合は参加できない" do
      brainstorm.brainstorm_members.create!(user: other_user, role: "editor")
      expect {
        post join_brainstorm_confirm_path(invitation.token)
      }.not_to change(BrainstormMember, :count)
    end
  end
end
