FactoryBot.define do
  factory :brainstorm_invitation do
    association :brainstorm
    role { "editor" }
  end
end
