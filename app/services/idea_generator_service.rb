class IdeaGeneratorService
  def initialize(brainstorm)
    @brainstorm = brainstorm
    @client = Anthropic::Client.new
  end

  def generate_ideas(count: 15)
    prompt = build_prompt(count)
    
    begin
      response = @client.messages(
        parameters: {
          model: 'claude-sonnet-4-20250514',
          max_tokens: 4000,
          messages: [
            { role: 'user', content: prompt }
          ]
        }
      )
      
      # レスポンスからアイデアを抽出
      ideas_text = response.dig('content', 0, 'text')
      parse_ideas(ideas_text)
    rescue StandardError => e
      Rails.logger.error "AI API Error: #{e.message}"
      []
    end
  end

  private

  def build_prompt(count)
    theme = @brainstorm.description.present? ? @brainstorm.description : @brainstorm.title
    
    <<~PROMPT
      以下のテーマについて、#{count}個のアイデアを生成してください。

      テーマ: #{theme}

      要件:
      - 各アイデアは具体的で実現可能なものにしてください
      - 多様な視点からアイデアを出してください
      - 各アイデアは1-2文程度の簡潔な説明にしてください
      - 以下の形式で出力してください（番号付きリスト）:

      1. [アイデア内容]
      2. [アイデア内容]
      ...
    PROMPT
  end

  def parse_ideas(text)
    return [] if text.blank?
    
    # 番号付きリストから各アイデアを抽出
    ideas = []
    text.scan(/^\d+\.\s*(.+)$/).each do |match|
      content = match[0].strip
      ideas << { content: content, source: 'ai' } if content.present?
    end
    
    ideas
  end
end
