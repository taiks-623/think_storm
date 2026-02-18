require 'rails_helper'

RSpec.describe "Groups", type: :request do
  let(:user) { create(:user) }
  let(:brainstorm) { create(:brainstorm, user: user) }

  describe "POST /brainstorms/:brainstorm_id/groups" do
    context "ログイン済みの場合" do
      before { login_as user, scope: :user }

      it "グループが作成されてブレスト詳細にリダイレクトされる" do
        expect {
          post brainstorm_groups_path(brainstorm), params: { group: { name: "テストグループ" } }
        }.to change(Group, :count).by(1)
        expect(response).to redirect_to(brainstorm_path(brainstorm))
      end

      it "名前が空の場合は作成されない" do
        expect {
          post brainstorm_groups_path(brainstorm), params: { group: { name: "" } }
        }.not_to change(Group, :count)
      end
    end

    context "未ログインの場合" do
      it "ログインページにリダイレクトされる" do
        post brainstorm_groups_path(brainstorm), params: { group: { name: "テスト" } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "他ユーザーのブレストの場合" do
      let(:other_user) { create(:user) }
      before { login_as other_user, scope: :user }

      it "404が返る" do
        post brainstorm_groups_path(brainstorm), params: { group: { name: "テスト" } }
        expect(response).to have_http_status(404)
      end
    end
  end

  describe "PATCH /brainstorms/:brainstorm_id/groups/:id" do
    let!(:group) { create(:group, brainstorm: brainstorm) }

    context "ログイン済みの場合" do
      before { login_as user, scope: :user }

      it "グループ名が更新されてブレスト詳細にリダイレクトされる" do
        patch brainstorm_group_path(brainstorm, group), params: { group: { name: "更新後のグループ名" } }
        expect(group.reload.name).to eq("更新後のグループ名")
        expect(response).to redirect_to(brainstorm_path(brainstorm))
      end

      it "名前が空の場合は更新されない" do
        original_name = group.name
        patch brainstorm_group_path(brainstorm, group), params: { group: { name: "" } }
        expect(group.reload.name).to eq(original_name)
      end
    end

    context "未ログインの場合" do
      it "ログインページにリダイレクトされる" do
        patch brainstorm_group_path(brainstorm, group), params: { group: { name: "更新" } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "他ユーザーのブレストの場合" do
      let(:other_user) { create(:user) }
      before { login_as other_user, scope: :user }

      it "404が返る" do
        patch brainstorm_group_path(brainstorm, group), params: { group: { name: "更新" } }
        expect(response).to have_http_status(404)
      end
    end
  end

  describe "DELETE /brainstorms/:brainstorm_id/groups/:id" do
    let!(:group) { create(:group, brainstorm: brainstorm) }

    context "ログイン済みの場合" do
      before { login_as user, scope: :user }

      it "グループが削除されてブレスト詳細にリダイレクトされる" do
        expect {
          delete brainstorm_group_path(brainstorm, group)
        }.to change(Group, :count).by(-1)
        expect(response).to redirect_to(brainstorm_path(brainstorm))
      end
    end

    context "未ログインの場合" do
      it "ログインページにリダイレクトされる" do
        delete brainstorm_group_path(brainstorm, group)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "他ユーザーのブレストの場合" do
      let(:other_user) { create(:user) }
      before { login_as other_user, scope: :user }

      it "404が返る" do
        delete brainstorm_group_path(brainstorm, group)
        expect(response).to have_http_status(404)
      end
    end
  end

  describe "POST /brainstorms/:brainstorm_id/groups/cluster" do
    let!(:idea) { create(:idea, brainstorm: brainstorm) }

    context "ログイン済みの場合" do
      before { login_as user, scope: :user }

      it "クラスタリングが成功するとブレスト詳細にリダイレクトされる" do
        allow_any_instance_of(IdeaClusteringService).to receive(:cluster_ideas).and_return({
          success: true,
          message: "クラスタリングが完了しました"
        })
        post cluster_brainstorm_groups_path(brainstorm)
        expect(response).to redirect_to(brainstorm_path(brainstorm))
      end

      it "クラスタリングが失敗するとalertでリダイレクトされる" do
        allow_any_instance_of(IdeaClusteringService).to receive(:cluster_ideas).and_return({
          success: false,
          message: "クラスタリングに失敗しました"
        })
        post cluster_brainstorm_groups_path(brainstorm)
        expect(response).to redirect_to(brainstorm_path(brainstorm))
      end
    end

    context "未ログインの場合" do
      it "ログインページにリダイレクトされる" do
        post cluster_brainstorm_groups_path(brainstorm)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "他ユーザーのブレストの場合" do
      let(:other_user) { create(:user) }
      before { login_as other_user, scope: :user }

      it "404が返る" do
        post cluster_brainstorm_groups_path(brainstorm)
        expect(response).to have_http_status(404)
      end
    end
  end

  describe "DELETE /brainstorms/:brainstorm_id/groups/reset_clustering" do
    let!(:group) { create(:group, brainstorm: brainstorm) }
    let!(:idea) { create(:idea, brainstorm: brainstorm) }
    let!(:idea_group) { create(:idea_group, idea: idea, group: group) }

    context "ログイン済みの場合" do
      before { login_as user, scope: :user }

      it "グループとidea_groupsが削除される" do
        allow_any_instance_of(IdeaClusteringService).to receive(:cluster_ideas).and_return({
          success: true,
          message: "クラスタリングが完了しました"
        })
        expect {
          delete reset_clustering_brainstorm_groups_path(brainstorm)
        }.to change(Group, :count).by(-1)
          .and change(IdeaGroup, :count).by(-1)
      end

      it "アイデア自体は削除されない" do
        allow_any_instance_of(IdeaClusteringService).to receive(:cluster_ideas).and_return({
          success: true,
          message: "クラスタリングが完了しました"
        })
        expect {
          delete reset_clustering_brainstorm_groups_path(brainstorm)
        }.not_to change(Idea, :count)
      end

      it "成功するとブレスト詳細にリダイレクトされる" do
        allow_any_instance_of(IdeaClusteringService).to receive(:cluster_ideas).and_return({
          success: true,
          message: "クラスタリングが完了しました"
        })
        delete reset_clustering_brainstorm_groups_path(brainstorm)
        expect(response).to redirect_to(brainstorm_path(brainstorm))
      end

      it "AIクラスタリングが失敗してもブレスト詳細にリダイレクトされる" do
        allow_any_instance_of(IdeaClusteringService).to receive(:cluster_ideas).and_return({
          success: false,
          message: "クラスタリングに失敗しました"
        })
        delete reset_clustering_brainstorm_groups_path(brainstorm)
        expect(response).to redirect_to(brainstorm_path(brainstorm))
      end
    end

    context "未ログインの場合" do
      it "ログインページにリダイレクトされる" do
        delete reset_clustering_brainstorm_groups_path(brainstorm)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "他ユーザーのブレストの場合" do
      let(:other_user) { create(:user) }
      before { login_as other_user, scope: :user }

      it "404が返る" do
        delete reset_clustering_brainstorm_groups_path(brainstorm)
        expect(response).to have_http_status(404)
      end
    end
  end
end
