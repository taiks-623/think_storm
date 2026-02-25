require "rails_helper"

RSpec.describe MarkdownExportService do
  let(:user) { create(:user) }
  let(:brainstorm) { create(:brainstorm, user: user, title: "テストブレスト", description: "説明文") }

  describe "#call" do
    it "タイトルと説明を含む" do
      result = MarkdownExportService.new(brainstorm).call
      expect(result).to include("# テストブレスト")
      expect(result).to include("説明文")
    end

    it "アイデアを含む" do
      create(:idea, brainstorm: brainstorm, content: "テストアイデア", source: "user")
      result = MarkdownExportService.new(brainstorm).call
      expect(result).to include("テストアイデア")
    end

    it "グループ別にアイデアを出力する" do
      group = create(:group, brainstorm: brainstorm, name: "グループA")
      idea = create(:idea, brainstorm: brainstorm, content: "グループ内アイデア", source: "user")
      create(:idea_group, idea: idea, group: group)
      result = MarkdownExportService.new(brainstorm).call
      expect(result).to include("### グループA")
      expect(result).to include("グループ内アイデア")
    end

    it "評価軸とスコアを含む" do
      axis = create(:evaluation_axis, brainstorm: brainstorm, name: "実現可能性")
      idea = create(:idea, brainstorm: brainstorm, content: "評価済みアイデア", source: "user")
      create(:evaluation, idea: idea, evaluation_axis: axis, score: 4)
      result = MarkdownExportService.new(brainstorm).call
      expect(result).to include("実現可能性: 4")
    end
  end
end
