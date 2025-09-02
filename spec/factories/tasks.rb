FactoryBot.define do
  factory :task do
    title { "MyString" }
    description { "MyText" }
    status { 1 }
    priority { 1 }
    due_date { "2025-09-03 00:05:13" }
    project { nil }
    user { nil }
  end
end
