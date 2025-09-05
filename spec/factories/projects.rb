FactoryBot.define do
  factory :project do
    sequence(:name) { |n| "Project #{n}" }
    description { "A sample project description" }
    visibility { "private_access" }
    association :user

    trait :shared do
      visibility { "shared" }
    end

    trait :public_access do
      visibility { "public_access" }
    end
  end
end
