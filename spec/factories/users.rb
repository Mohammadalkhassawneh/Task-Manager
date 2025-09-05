FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "User #{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    role { "user" }

    trait :admin do
      role { "admin" }
      sequence(:email) { |n| "admin#{n}@example.com" }
    end
  end
end
