require 'rails_helper'

RSpec.describe IdeaDeepDiveService do
  let(:user) { create(:user) }
  let(:brainstorm) { create(:brainstorm, user: user) }
  let(:idea) { create(:idea, brainstorm: brainstorm) }
  let(:conversation) { create(:conversation, brainstorm: brainstorm, idea: idea) }
  let(:service) { described_class.new(conversation) }

  describe "#chat" do
    context "APIが成功した場合" do
      before do
        allow_any_instance_of(Anthropic::Client).to receive(:messages).and_return(
          { "content" => [{ "text" => "AIからの返答です" }] }
        )
      end

      it "ユーザーメッセージが保存される" do
        expect {
          service.chat("テスト質問")
        }.to change(Message, :count).by(2)
      end

      it "successがtrueで返る" do
        result = service.chat("テスト質問")
        expect(result[:success]).to be true
      end

      it "AIの返答が含まれる" do
        result = service.chat("テスト質問")
        expect(result[:message]).to eq("AIからの返答です")
      end

      it "ユーザーメッセージのroleがuserになる" do
        service.chat("テスト質問")
        expect(conversation.messages.first.role).to eq("user")
      end

      it "アシスタントメッセージのroleがassistantになる" do
        service.chat("テスト質問")
        expect(conversation.messages.last.role).to eq("assistant")
      end
    end

    context "APIが失敗した場合" do
      before do
        allow_any_instance_of(Anthropic::Client).to receive(:messages).and_raise(StandardError)
      end

      it "successがfalseで返る" do
        result = service.chat("テスト質問")
        expect(result[:success]).to be false
      end

      it "エラーメッセージが含まれる" do
        result = service.chat("テスト質問")
        expect(result[:message]).to be_present
      end
    end
  end
end
