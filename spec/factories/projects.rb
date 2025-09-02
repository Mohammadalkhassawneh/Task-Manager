FactoryBot.define do
  factory :project do
    name { "MyString" }
    description { "MyText" }
    visibility { 1 }
    user { nil }
  end
end
