require "rails_helper"

RSpec.describe EvaluationAxis, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:brainstorm) }
    it { is_expected.to have_many(:evaluations).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe "自動削除" do
    it "評価軸を削除すると関連する評価も削除される" do
      axis = create(:evaluation_axis)
      idea = create(:idea, brainstorm: axis.brainstorm)
      create(:evaluation, idea: idea, evaluation_axis: axis)
      expect { axis.destroy }.to change(Evaluation, :count).by(-1)
    end
  end
end
