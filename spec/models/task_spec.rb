require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:priority) }
  end

  describe 'associations' do
    it { should belong_to(:project) }
    it { should belong_to(:user) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(pending: 0, in_progress: 1, completed: 2, cancelled: 3) }
    it { should define_enum_for(:priority).with_values(low: 0, medium: 1, high: 2, urgent: 3) }
  end

  describe 'scopes' do
    let(:user) { create(:user) }
    let(:project) { create(:project, user: user) }
    let!(:pending_task) { create(:task, project: project, status: 'pending', user: user) }
    let!(:completed_task) { create(:task, project: project, status: 'completed', user: user) }
    let!(:high_priority_task) { create(:task, project: project, priority: 'high', user: user) }
    let!(:low_priority_task) { create(:task, project: project, priority: 'low', user: user) }

    describe '.by_status' do
      it 'filters tasks by status' do
        expect(Task.by_status('pending')).to include(pending_task)
        expect(Task.by_status('pending')).not_to include(completed_task)
      end

      it 'returns all tasks when status is blank' do
        expect(Task.by_status('')).to include(pending_task, completed_task)
      end
    end

    describe '.by_priority' do
      it 'filters tasks by priority' do
        expect(Task.by_priority('high')).to include(high_priority_task)
        expect(Task.by_priority('high')).not_to include(low_priority_task)
      end

      it 'returns all tasks when priority is blank' do
        expect(Task.by_priority('')).to include(high_priority_task, low_priority_task)
      end
    end
  end

  describe 'validation: user_can_create_task_in_project' do
    let(:project_owner) { create(:user) }
    let(:project) { create(:project, user: project_owner) }
    let(:regular_user) { create(:user) }

    context 'when user has access to project' do
      it 'allows task creation by project owner' do
        task = build(:task, project: project, user: project_owner)
        expect(task).to be_valid
      end

      it 'allows task creation by permitted user' do
        create(:project_permission, project: project, user: regular_user)
        project.update(visibility: 'shared')
        task = build(:task, project: project, user: regular_user)
        expect(task).to be_valid
      end

      it 'allows task creation in public project' do
        project.update(visibility: 'public_access')
        task = build(:task, project: project, user: regular_user)
        expect(task).to be_valid
      end
    end

    context 'when user does not have access to project' do
      it 'prevents task creation in private project' do
        project.update(visibility: 'private_access')
        task = build(:task, project: project, user: regular_user)
        expect(task).not_to be_valid
        expect(task.errors[:project]).to include('is not accessible by this user')
      end

      it 'prevents task creation in shared project without permission' do
        project.update(visibility: 'shared')
        task = build(:task, project: project, user: regular_user)
        expect(task).not_to be_valid
        expect(task.errors[:project]).to include('is not accessible by this user')
      end
    end
  end
end
