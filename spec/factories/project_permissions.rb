FactoryBot.define do
  factory :project_permission do
    association :user
    association :project
    permission_type { "read" }

    trait :write_permission do
      permission_type { "write" }
    end
  end
end
