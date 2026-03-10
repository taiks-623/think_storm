class IdeaDeepDiveService
  def initialize(conversation)
    @conversation = conversation
    @idea = conversation.idea
    @brainstorm = conversation.brainstorm
    @client = Anthropic::Client.new
  end

  def chat(user_message)
    # ユーザーメッセージを保存
    @conversation.messages.create!(role: "user", content: user_message)

    # 会話履歴を構築
    messages = build_messages

    begin
      response = @client.messages(
        parameters: {
          model: "claude-sonnet-4-20250514",
          max_tokens: 2000,
          system: build_system_prompt,
          messages: messages
        }
      )

      assistant_message = response.dig("content", 0, "text")

      # アシスタントのメッセージを保存
      @conversation.messages.create!(role: "assistant", content: assistant_message)

      { success: true, message: assistant_message }
    rescue StandardError => e
      Rails.logger.error "AI DeepDive Error: #{e.message}"
      { success: false, message: "エラーが発生しました。もう一度お試しください。" }
    end
  end

  private

  def build_system_prompt
    <<~PROMPT
      あなたはブレインストーミングの専門家です。
      以下のアイデアについてユーザーと深掘り対話を行ってください。

      ブレストテーマ: #{@brainstorm.title}
      対象アイデア: #{@idea.content}

      対話の目的:
      - アイデアの具体化・実現可能性の検討
      - 課題や懸念点の洗い出し
      - 改善案や派生アイデアの提案
      - 実行に向けた次のステップの提案

      回答は簡潔で分かりやすく、200文字程度を目安にしてください。
      マークダウン記法（**や#など）は使わず、プレーンテキストで回答してください。
    PROMPT
  end

  def build_messages
    @conversation.messages.order(:created_at).map do |message|
      { role: message.role, content: message.content }
    end
  end
end
