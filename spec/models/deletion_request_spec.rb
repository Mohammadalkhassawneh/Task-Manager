require 'rails_helper'

RSpec.describe DeletionRequest, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:reason) }
    it { should validate_presence_of(:status) }
  end

  describe 'associations' do
    it { should belong_to(:project) }
    it { should belong_to(:user) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(pending: 0, approved: 1, rejected: 2) }
  end

  describe 'uniqueness validation' do
    let(:project) { create(:project) }
    let(:user) { create(:user) }

    it 'prevents duplicate pending requests for same user and project' do
      create(:deletion_request, project: project, user: user, status: 'pending')
      duplicate_request = build(:deletion_request, project: project, user: user, status: 'pending')

      expect(duplicate_request).not_to be_valid
      expect(duplicate_request.errors[:project_id]).to include('has already been taken')
    end

    it 'allows new request after previous one is processed' do
      create(:deletion_request, project: project, user: user, status: 'approved')
      new_request = build(:deletion_request, project: project, user: user, status: 'pending')

      expect(new_request).to be_valid
    end

    it 'allows different users to request deletion of same project' do
      other_user = create(:user)
      create(:deletion_request, project: project, user: user, status: 'pending')
      other_request = build(:deletion_request, project: project, user: other_user, status: 'pending')

      expect(other_request).to be_valid
    end
  end

  describe 'callbacks' do
    describe '#notify_admin' do
      it 'logs admin notification after creation' do
        project = create(:project, name: 'Test Project')
        user = create(:user, name: 'John Doe', email: 'john@example.com')

        expect(Rails.logger).to receive(:info).with(
          "Deletion request created for project 'Test Project' by John Doe (john@example.com). Reason: No longer needed"
        )

        create(:deletion_request,
               project: project,
               user: user,
               reason: 'No longer needed')
      end
    end
  end

  describe 'status transitions' do
    let(:deletion_request) { create(:deletion_request) }

    it 'starts with pending status' do
      expect(deletion_request.pending?).to be true
    end

    it 'can be approved' do
      deletion_request.update(status: 'approved')
      expect(deletion_request.approved?).to be true
    end

    it 'can be rejected' do
      deletion_request.update(status: 'rejected')
      expect(deletion_request.rejected?).to be true
    end
  end
end
