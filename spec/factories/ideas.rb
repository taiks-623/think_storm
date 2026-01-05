FactoryBot.define do
  factory :idea do
    brainstorm { nil }
    content { "MyText" }
    source { "MyString" }
    memo { "MyText" }
    position { 1 }
  end
end
