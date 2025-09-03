class ProjectPermission < ApplicationRecord
  belongs_to :user
  belongs_to :project

  enum :permission_type, { read: 0, write: 1 }

  validates :permission_type, presence: true
  validates :user_id, uniqueness: { scope: :project_id }
end
