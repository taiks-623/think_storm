require 'rails_helper'

RSpec.describe "Comments", type: :request do
  let(:user) { create(:user) }
  let(:brainstorm) { create(:brainstorm, user: user) }
  let(:idea) { create(:idea, brainstorm: brainstorm) }

  describe "POST /brainstorms/:brainstorm_id/ideas/:idea_id/comments" do
    context "ログイン済みの場合" do
      before { login_as user, scope: :user }

      it "コメントを投稿できる" do
        expect {
          post brainstorm_idea_comments_path(brainstorm, idea),
               params: { content: "テストコメント" }
        }.to change(Comment, :count).by(1)
      end

      it "内容が空の場合は投稿できない" do
        expect {
          post brainstorm_idea_comments_path(brainstorm, idea),
               params: { content: "" }
        }.not_to change(Comment, :count)
      end
    end

    context "未ログインの場合" do
      it "ログインページにリダイレクトされる" do
        post brainstorm_idea_comments_path(brainstorm, idea),
             params: { content: "テスト" }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "他ユーザーのブレストの場合" do
      let(:other_user) { create(:user) }
      before { login_as other_user, scope: :user }

      it "404が返る" do
        post brainstorm_idea_comments_path(brainstorm, idea),
             params: { content: "テスト" }
        expect(response).to have_http_status(404)
      end
    end
  end

  describe "DELETE /brainstorms/:brainstorm_id/ideas/:idea_id/comments/:id" do
    let!(:comment) { create(:comment, idea: idea, user: user) }

    context "コメント投稿者の場合" do
      before { login_as user, scope: :user }

      it "コメントを削除できる" do
        expect {
          delete brainstorm_idea_comment_path(brainstorm, idea, comment)
        }.to change(Comment, :count).by(-1)
      end
    end

    context "オーナーの場合" do
      let(:other_user) { create(:user) }
      let!(:other_comment) { create(:comment, idea: idea, user: other_user) }
      before { login_as user, scope: :user }

      it "他ユーザーのコメントも削除できる" do
        expect {
          delete brainstorm_idea_comment_path(brainstorm, idea, other_comment)
        }.to change(Comment, :count).by(-1)
      end
    end

    context "関係のないユーザーの場合" do
      let(:other_user) { create(:user) }
      before { login_as other_user, scope: :user }

      it "404が返る" do
        delete brainstorm_idea_comment_path(brainstorm, idea, comment)
        expect(response).to have_http_status(404)
      end
    end

    context "未ログインの場合" do
      it "ログインページにリダイレクトされる" do
        delete brainstorm_idea_comment_path(brainstorm, idea, comment)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
