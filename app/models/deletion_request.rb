class DeletionRequest < ApplicationRecord
  belongs_to :project
  belongs_to :user

  enum status: { pending: 0, approved: 1, rejected: 2 }

  validates :reason, presence: true
  validates :status, presence: true
  validates :project_id, uniqueness: { scope: :user_id, conditions: -> { where(status: :pending) } }

  after_create :notify_admin

  private

  def notify_admin
    Rails.logger.info "🚨 Deletion request created for project '#{project.name}' by #{user.name} (#{user.email}). Reason: #{reason}"
  end
end
