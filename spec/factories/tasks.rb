FactoryBot.define do
  factory :task do
    sequence(:title) { |n| "Task #{n}" }
    description { "A sample task description" }
    status { "pending" }
    priority { "medium" }
    due_date { 1.week.from_now }
    association :project

    user { project.user }

    trait :completed do
      status { "completed" }
    end

    trait :high_priority do
      priority { "high" }
    end

    trait :urgent do
      priority { "urgent" }
    end
  end
end
