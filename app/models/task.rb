class Task < ApplicationRecord
  belongs_to :project
  belongs_to :user

  enum :status, { pending: 0, in_progress: 1, completed: 2, cancelled: 3 }
  enum :priority, { low: 0, medium: 1, high: 2, urgent: 3 }

  validates :title, presence: true
  validates :description, presence: true
  validates :status, presence: true
  validates :priority, presence: true

  validate :user_can_create_task_in_project

  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :by_priority, ->(priority) { where(priority: priority) if priority.present? }

  private

  def user_can_create_task_in_project
    return unless project && user

    unless project.accessible_by?(user)
      errors.add(:project, "is not accessible by this user")
    end
  end
end
