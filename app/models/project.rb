class Project < ApplicationRecord
  belongs_to :user

  enum :visibility, { private_access: 0, shared: 1, public_access: 2 }

  validates :name, presence: true
  validates :description, presence: true
  validates :visibility, presence: true

  has_many :tasks, dependent: :destroy
  has_many :project_permissions, dependent: :destroy
  has_many :permitted_users, through: :project_permissions, source: :user
  has_many :deletion_requests, dependent: :destroy

  def accessible_by?(user)
    return false unless user

    user.admin? ||
    self.user == user ||
    public_access? ||
    (shared? && permitted_users.include?(user))
  end
end
