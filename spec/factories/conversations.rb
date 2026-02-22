FactoryBot.define do
  factory :conversation do
    association :brainstorm
    association :idea
  end
end
