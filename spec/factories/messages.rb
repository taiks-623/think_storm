FactoryBot.define do
  factory :message do
    association :conversation
    role { "user" }
    content { "テストメッセージ" }
  end
end
