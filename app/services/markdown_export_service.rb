class MarkdownExportService
  def initialize(brainstorm)
    @brainstorm = brainstorm
  end

  def call
    lines = []
    lines << "# #{@brainstorm.title}"
    lines << ""
    if @brainstorm.description.present?
      lines << @brainstorm.description
      lines << ""
    end
    lines << "作成日: #{@brainstorm.created_at.strftime('%Y年%m月%d日')}"
    lines << ""

    lines << "## アイデア一覧"
    lines << ""

    if @brainstorm.groups.any?
      @brainstorm.groups.order(:position).each do |group|
        lines << "### #{group.name}"
        lines << ""
        group.ideas.each { |idea| lines.concat(idea_lines(idea)) }
        lines << ""
      end

      ungrouped = @brainstorm.ideas.left_joins(:idea_groups).where(idea_groups: { id: nil })
      if ungrouped.any?
        lines << "### 未分類"
        lines << ""
        ungrouped.each { |idea| lines.concat(idea_lines(idea)) }
        lines << ""
      end
    else
      @brainstorm.ideas.each { |idea| lines.concat(idea_lines(idea)) }
      lines << ""
    end

    if @brainstorm.evaluation_axes.any?
      lines << "## 評価軸"
      lines << ""
      @brainstorm.evaluation_axes.order(:created_at).each do |axis|
        lines << "- #{axis.name}"
      end
      lines << ""
    end

    lines.join("\n")
  end

  private

  def idea_lines(idea)
    result = [ "- #{idea.content}" ]
    result << "  - メモ: #{idea.memo}" if idea.memo.present?
    if @brainstorm.evaluation_axes.any?
      scores = @brainstorm.evaluation_axes.order(:created_at).map do |axis|
        score = idea.evaluations.find { |e| e.evaluation_axis_id == axis.id }&.score
        "#{axis.name}: #{score || '未評価'}"
      end
      result << "  - 評価: #{scores.join(' / ')}"
    end
    result
  end
end
