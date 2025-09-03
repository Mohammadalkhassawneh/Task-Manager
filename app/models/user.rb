class User < ApplicationRecord
  has_secure_password

  enum :role, { user: 0, admin: 1 }

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }

  has_many :projects, dependent: :destroy
  has_many :tasks, dependent: :destroy
  has_many :project_permissions, dependent: :destroy
  has_many :permitted_projects, through: :project_permissions, source: :project
end
