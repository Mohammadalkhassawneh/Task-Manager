class ProjectPermission < ApplicationRecord
  belongs_to :user
  belongs_to :project

  validates :permission_type, presence: true, inclusion: { in: %w[read write admin] }
  validates :user_id, uniqueness: { scope: :project_id }
end
