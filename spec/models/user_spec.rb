require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { build(:user) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
    it { should validate_length_of(:password).is_at_least(6) }

    it 'validates email format' do
      user = build(:user, email: 'invalid-email')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('is invalid')
    end
  end

  describe 'associations' do
    it { should have_many(:projects).dependent(:destroy) }
    it { should have_many(:tasks).dependent(:destroy) }
    it { should have_many(:project_permissions).dependent(:destroy) }
    it { should have_many(:permitted_projects).through(:project_permissions) }
  end

  describe 'enums' do
    it { should define_enum_for(:role).with_values(user: 0, admin: 1) }
  end

  describe 'password encryption' do
    it 'encrypts password on creation' do
      user = create(:user, password: 'password123')
      expect(user.password_digest).to be_present
      expect(user.password_digest).not_to eq('password123')
    end

    it 'authenticates with correct password' do
      user = create(:user, password: 'password123')
      expect(user.authenticate('password123')).to eq(user)
      expect(user.authenticate('wrong')).to be_falsey
    end
  end

  describe 'roles' do
    it 'defaults to user role' do
      user = create(:user)
      expect(user.user?).to be true
      expect(user.admin?).to be false
    end

    it 'can be created as admin' do
      admin = create(:user, role: 'admin')
      expect(admin.admin?).to be true
      expect(admin.user?).to be false
    end
  end
end
