FactoryBot.define do
  factory :vote do
    association :idea
    association :user
  end
end
