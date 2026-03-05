FactoryBot.define do
  factory :brainstorm_member do
    association :brainstorm
    association :user
    role { "editor" }
  end
end
