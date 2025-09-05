require 'rails_helper'

RSpec.describe ProjectPermission, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:permission_type) }
  end

  describe 'associations' do
    it { should belong_to(:project) }
    it { should belong_to(:user) }
  end

  describe 'enums' do
    it { should define_enum_for(:permission_type).with_values(read: 0, write: 1) }
  end

  describe 'uniqueness validation' do
    let(:project) { create(:project) }
    let(:user) { create(:user) }

    it 'prevents duplicate permissions for same user and project' do
      create(:project_permission, project: project, user: user)
      duplicate_permission = build(:project_permission, project: project, user: user)

      expect(duplicate_permission).not_to be_valid
      expect(duplicate_permission.errors[:user_id]).to include('has already been taken')
    end

    it 'allows same user to have permissions on different projects' do
      other_project = create(:project)
      create(:project_permission, project: project, user: user)
      other_permission = build(:project_permission, project: other_project, user: user)

      expect(other_permission).to be_valid
    end

    it 'allows different users to have permissions on same project' do
      other_user = create(:user)
      create(:project_permission, project: project, user: user)
      other_permission = build(:project_permission, project: project, user: other_user)

      expect(other_permission).to be_valid
    end
  end
end
