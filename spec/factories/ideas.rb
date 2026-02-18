FactoryBot.define do
  factory :idea do
    association :brainstorm
    sequence(:content) { |n| "テストアイデア#{n}" }
    source { "user" }
    memo { nil }
    position { 1 }
  end
end
