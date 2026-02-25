FactoryBot.define do
  factory :evaluation_axis do
    association :brainstorm
    sequence(:name) { |n| "評価軸#{n}" }
    position { nil }
  end
end
