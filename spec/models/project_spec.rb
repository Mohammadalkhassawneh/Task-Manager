require 'rails_helper'

RSpec.describe Project, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:visibility) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:tasks).dependent(:destroy) }
    it { should have_many(:project_permissions).dependent(:destroy) }
    it { should have_many(:permitted_users).through(:project_permissions) }
    it { should have_many(:deletion_requests).dependent(:destroy) }
  end

  describe 'enums' do
    it { should define_enum_for(:visibility).with_values(private_access: 0, shared: 1, public_access: 2) }
  end

  describe '#accessible_by?' do
    let(:owner) { create(:user) }
    let(:admin) { create(:user, role: 'admin') }
    let(:regular_user) { create(:user) }
    let(:permitted_user) { create(:user) }

    context 'private project' do
      let(:project) { create(:project, visibility: 'private_access', user: owner) }

      it 'allows access to owner' do
        expect(project.accessible_by?(owner)).to be true
      end

      it 'allows access to admin' do
        expect(project.accessible_by?(admin)).to be true
      end

      it 'denies access to regular user' do
        expect(project.accessible_by?(regular_user)).to be false
      end

      it 'denies access when user is nil' do
        expect(project.accessible_by?(nil)).to be false
      end
    end

    context 'shared project' do
      let(:project) { create(:project, visibility: 'shared', user: owner) }

      before do
        create(:project_permission, project: project, user: permitted_user)
      end

      it 'allows access to owner' do
        expect(project.accessible_by?(owner)).to be true
      end

      it 'allows access to admin' do
        expect(project.accessible_by?(admin)).to be true
      end

      it 'allows access to permitted user' do
        expect(project.accessible_by?(permitted_user)).to be true
      end

      it 'denies access to non-permitted user' do
        expect(project.accessible_by?(regular_user)).to be false
      end
    end

    context 'public project' do
      let(:project) { create(:project, visibility: 'public_access', user: owner) }

      it 'allows access to any authenticated user' do
        expect(project.accessible_by?(regular_user)).to be true
        expect(project.accessible_by?(permitted_user)).to be true
        expect(project.accessible_by?(admin)).to be true
        expect(project.accessible_by?(owner)).to be true
      end

      it 'denies access when user is nil' do
        expect(project.accessible_by?(nil)).to be false
      end
    end
  end
end
