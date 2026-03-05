FactoryBot.define do
  factory :comment do
    association :idea
    association :user
    content { "テストコメント" }
  end
end
