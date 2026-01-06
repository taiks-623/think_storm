class IdeaClusteringService
  def initialize(brainstorm)
    @brainstorm = brainstorm
    @client = Anthropic::Client.new
  end

  def cluster_ideas
    ideas = @brainstorm.ideas.where.not(id: nil)
    return { success: false, message: "クラスタリングするアイデアがありません" } if ideas.empty?

    prompt = build_clustering_prompt(ideas)
    
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
      
      clustering_result = response.dig('content', 0, 'text')
      apply_clustering(clustering_result, ideas)
      
      { success: true, message: "クラスタリングが完了しました" }
    rescue StandardError => e
      Rails.logger.error "AI Clustering Error: #{e.message}"
      { success: false, message: "クラスタリングに失敗しました" }
    end
  end

  private

  def build_clustering_prompt(ideas)
    ideas_list = ideas.map.with_index(1) do |idea, index|
      "#{index}. #{idea.content}"
    end.join("\n")
    
    <<~PROMPT
      以下のアイデア群を類似性に基づいて3-5個のグループにクラスタリングしてください。

      アイデア一覧:
      #{ideas_list}

      要件:
      - 類似したテーマや性質を持つアイデアを同じグループにまとめてください
      - 各グループに適切なカテゴリ名（10文字以内）を付けてください
      - 以下のJSON形式で出力してください（JSONのみを出力し、説明文は不要）:

      {
        "clusters": [
          {
            "name": "グループ名",
            "idea_indices": [1, 3, 5]
          },
          {
            "name": "グループ名",
            "idea_indices": [2, 4]
          }
        ]
      }

      注意: 
      - idea_indicesは上記のアイデア一覧の番号（1から始まる）を指定してください
      - すべてのアイデアをいずれかのグループに含めてください
      - JSONのみを出力してください
    PROMPT
  end

  def apply_clustering(clustering_result, ideas)
    # 既存のグループとアイデアグループの関連を削除
    @brainstorm.groups.destroy_all
    
    # JSONをパース
    json_start = clustering_result.index('{')
    json_end = clustering_result.rindex('}')
    return unless json_start && json_end
    
    json_str = clustering_result[json_start..json_end]
    result = JSON.parse(json_str)
    
    ideas_array = ideas.to_a
    
    result['clusters'].each_with_index do |cluster, position|
      group = @brainstorm.groups.create!(
        name: cluster['name'],
        position: position
      )
      
      cluster['idea_indices'].each do |index|
        idea = ideas_array[index - 1] # 1-indexedなので-1
        group.ideas << idea if idea
      end
    end
  rescue JSON::ParserError => e
    Rails.logger.error "JSON Parse Error: #{e.message}"
    Rails.logger.error "Clustering Result: #{clustering_result}"
  end
end
