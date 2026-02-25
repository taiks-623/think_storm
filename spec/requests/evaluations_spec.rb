require "rails_helper"

RSpec.describe "Evaluations", type: :request do
  let(:user) { create(:user) }
  let(:brainstorm) { create(:brainstorm, user: user) }
  let(:idea) { create(:idea, brainstorm: brainstorm) }
  let(:axis) { create(:evaluation_axis, brainstorm: brainstorm) }

  describe "POST /brainstorms/:brainstorm_id/ideas/:idea_id/evaluations" do
    context "ログイン済み" do
      before { sign_in user }

      it "評価を作成できる" do
        expect {
          post brainstorm_idea_evaluations_path(brainstorm, idea),
            params: { score: 3, evaluation_axis_id: axis.id },
            headers: { "Accept" => "text/vnd.turbo-stream.html" }
        }.to change(Evaluation, :count).by(1)
      end

      it "他ユーザーのアイデアは評価できない" do
        other_brainstorm = create(:brainstorm)
        other_idea = create(:idea, brainstorm: other_brainstorm)
        post brainstorm_idea_evaluations_path(other_brainstorm, other_idea),
          params: { score: 3, evaluation_axis_id: axis.id }
        expect(response).to have_http_status(:not_found)
      end
    end

    context "未ログイン" do
      it "リダイレクトされる" do
        post brainstorm_idea_evaluations_path(brainstorm, idea),
          params: { score: 3, evaluation_axis_id: axis.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "PATCH /brainstorms/:brainstorm_id/ideas/:idea_id/evaluations/:id" do
    let!(:evaluation) { create(:evaluation, idea: idea, evaluation_axis: axis, score: 3) }

    context "ログイン済み" do
      before { sign_in user, scope: :user }

      it "評価を更新できる" do
        patch brainstorm_idea_evaluation_path(brainstorm, idea, evaluation),
          params: { score: 5 },
          headers: { "Accept" => "text/vnd.turbo-stream.html" }
        expect(evaluation.reload.score).to eq(5)
      end
    end

    context "未ログイン" do
      it "リダイレクトされる" do
        patch brainstorm_idea_evaluation_path(brainstorm, idea, evaluation),
          params: { score: 5 }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
