FactoryBot.define do
  factory :brainstorm do
    association :user
    title { "MyString" }
    description { "MyText" }
  end
end
