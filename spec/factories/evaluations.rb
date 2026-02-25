FactoryBot.define do
  factory :evaluation do
    association :idea
    association :evaluation_axis
    score { 3 }
  end
end
