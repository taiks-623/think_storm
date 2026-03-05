require 'rails_helper'

RSpec.describe "Votes", type: :request do
  let(:user) { create(:user) }
  let(:brainstorm) { create(:brainstorm, user: user) }
  let(:idea) { create(:idea, brainstorm: brainstorm) }

  describe "POST /brainstorms/:brainstorm_id/ideas/:idea_id/vote" do
    context "ログイン済みの場合" do
      before { login_as user, scope: :user }

      it "投票できる" do
        expect {
          post brainstorm_idea_vote_path(brainstorm, idea)
        }.to change(Vote, :count).by(1)
      end

      it "2重投票できない" do
        create(:vote, idea: idea, user: user)
        expect {
          post brainstorm_idea_vote_path(brainstorm, idea)
        }.not_to change(Vote, :count)
      end
    end

    context "未ログインの場合" do
      it "ログインページにリダイレクトされる" do
        post brainstorm_idea_vote_path(brainstorm, idea)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "他ユーザーのブレストの場合" do
      let(:other_user) { create(:user) }
      before { login_as other_user, scope: :user }

      it "404が返る" do
        post brainstorm_idea_vote_path(brainstorm, idea)
        expect(response).to have_http_status(404)
      end
    end
  end

  describe "DELETE /brainstorms/:brainstorm_id/ideas/:idea_id/vote" do
    context "ログイン済みの場合" do
      before do
        login_as user, scope: :user
        create(:vote, idea: idea, user: user)
      end

      it "投票を取り消せる" do
        expect {
          delete brainstorm_idea_vote_path(brainstorm, idea)
        }.to change(Vote, :count).by(-1)
      end
    end

    context "未ログインの場合" do
      it "ログインページにリダイレクトされる" do
        delete brainstorm_idea_vote_path(brainstorm, idea)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
