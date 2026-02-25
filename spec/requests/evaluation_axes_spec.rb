require "rails_helper"

RSpec.describe "EvaluationAxes", type: :request do
  let(:user) { create(:user) }
  let(:brainstorm) { create(:brainstorm, user: user) }

  describe "POST /brainstorms/:brainstorm_id/evaluation_axes" do
    context "ログイン済み" do
      before { sign_in user, scope: :user }

      it "評価軸を作成できる" do
        expect {
          post brainstorm_evaluation_axes_path(brainstorm),
            params: { evaluation_axis: { name: "実現可能性" } }
        }.to change(EvaluationAxis, :count).by(1)
      end

      it "他ユーザーのブレストには作成できない" do
        other_brainstorm = create(:brainstorm)
        post brainstorm_evaluation_axes_path(other_brainstorm),
          params: { evaluation_axis: { name: "実現可能性" } }
        expect(response).to have_http_status(:not_found)
      end
    end

    context "未ログイン" do
      it "リダイレクトされる" do
        post brainstorm_evaluation_axes_path(brainstorm),
          params: { evaluation_axis: { name: "実現可能性" } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "DELETE /brainstorms/:brainstorm_id/evaluation_axes/:id" do
    let!(:axis) { create(:evaluation_axis, brainstorm: brainstorm) }

    context "ログイン済み" do
      before { sign_in user, scope: :user }

      it "評価軸を削除できる" do
        expect {
          delete brainstorm_evaluation_ax_path(brainstorm, axis)
        }.to change(EvaluationAxis, :count).by(-1)
      end

      it "他ユーザーの評価軸は削除できない" do
        other_brainstorm = create(:brainstorm)
        other_axis = create(:evaluation_axis, brainstorm: other_brainstorm)
        delete brainstorm_evaluation_ax_path(other_brainstorm, other_axis)
        expect(response).to have_http_status(:not_found)
      end
    end

    context "未ログイン" do
      it "リダイレクトされる" do
        delete brainstorm_evaluation_ax_path(brainstorm, axis)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
