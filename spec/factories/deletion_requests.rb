FactoryBot.define do
  factory :deletion_request do
    association :project
    association :user
    reason { "No longer needed" }
    status { "pending" }
    admin_notes { nil }

    trait :approved do
      status { "approved" }
      admin_notes { "Request approved" }
    end

    trait :rejected do
      status { "rejected" }
      admin_notes { "Request rejected" }
    end
  end
end
