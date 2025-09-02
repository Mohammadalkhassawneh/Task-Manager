FactoryBot.define do
  factory :project_permission do
    user { nil }
    project { nil }
    permission_type { "MyString" }
  end
end
