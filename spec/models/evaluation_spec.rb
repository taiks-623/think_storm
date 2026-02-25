require "rails_helper"

RSpec.describe Evaluation, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:idea) }
    it { is_expected.to belong_to(:evaluation_axis) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:score) }
    it { is_expected.to validate_numericality_of(:score).is_greater_than_or_equal_to(1).is_less_than_or_equal_to(5).only_integer }

    it "同じアイデアと評価軸の組み合わせは一意" do
      axis = create(:evaluation_axis)
      idea = create(:idea, brainstorm: axis.brainstorm)
      create(:evaluation, idea: idea, evaluation_axis: axis)
      duplicate = build(:evaluation, idea: idea, evaluation_axis: axis)
      expect(duplicate).not_to be_valid
    end
  end
end
