FactoryBot.define do
  factory :deletion_request do
    project { nil }
    user { nil }
    reason { "MyText" }
    status { 1 }
  end
end
