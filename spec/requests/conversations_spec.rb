require 'rails_helper'

RSpec.describe "Conversations", type: :request do
  let(:user) { create(:user) }
  let(:brainstorm) { create(:brainstorm, user: user) }
  let(:idea) { create(:idea, brainstorm: brainstorm) }

  describe "GET /brainstorms/:brainstorm_id/ideas/:idea_id/conversation" do
    context "ログイン済みの場合" do
      before { login_as user, scope: :user }

      it "正常にレスポンスが返る" do
        get brainstorm_idea_conversation_path(brainstorm, idea)
        expect(response).to have_http_status(200)
      end

      it "conversationが自動作成される" do
        expect {
          get brainstorm_idea_conversation_path(brainstorm, idea)
        }.to change(Conversation, :count).by(1)
      end

      it "2回アクセスしてもconversationが増えない" do
        get brainstorm_idea_conversation_path(brainstorm, idea)
        expect {
          get brainstorm_idea_conversation_path(brainstorm, idea)
        }.not_to change(Conversation, :count)
      end
    end

    context "未ログインの場合" do
      it "ログインページにリダイレクトされる" do
        get brainstorm_idea_conversation_path(brainstorm, idea)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "他ユーザーのブレストの場合" do
      let(:other_user) { create(:user) }
      before { login_as other_user, scope: :user }

      it "404が返る" do
        get brainstorm_idea_conversation_path(brainstorm, idea)
        expect(response).to have_http_status(404)
      end
    end
  end

  describe "POST /brainstorms/:brainstorm_id/ideas/:idea_id/conversation" do
    context "ログイン済みの場合" do
      before do
        login_as user, scope: :user
        allow_any_instance_of(Anthropic::Client).to receive(:messages).and_return(
          { "content" => [{ "text" => "AIからの返答です" }] }
        )
      end

      it "メッセージが2件作成される" do
        expect {
          post brainstorm_idea_conversation_path(brainstorm, idea),
            params: { message: "テスト質問" }
        }.to change(Message, :count).by(2)
      end

      it "Turbo Streamでレスポンスが返る" do
        post brainstorm_idea_conversation_path(brainstorm, idea),
          params: { message: "テスト質問" },
          headers: { "Accept" => "text/vnd.turbo-stream.html" }
        expect(response.content_type).to include("text/vnd.turbo-stream.html")
      end
    end

    context "未ログインの場合" do
      it "ログインページにリダイレクトされる" do
        post brainstorm_idea_conversation_path(brainstorm, idea),
          params: { message: "テスト質問" }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "他ユーザーのブレストの場合" do
      let(:other_user) { create(:user) }
      before { login_as other_user, scope: :user }

      it "404が返る" do
        post brainstorm_idea_conversation_path(brainstorm, idea),
          params: { message: "テスト質問" }
        expect(response).to have_http_status(404)
      end
    end
  end
end
