require 'rails_helper'

RSpec.describe Api::V1::ProjectsController, type: :controller do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:other_user) { create(:user) }

  describe 'GET #index' do
    let!(:user_project) { create(:project, user: user) }
    let!(:public_project) { create(:project, :public_access, user: other_user) }
    let!(:private_project) { create(:project, user: other_user) }

    context 'as regular user' do
      before { request.headers.merge!(authenticated_headers(user)) }

      it 'returns accessible projects' do
        get :index

        expect(response).to have_http_status(:ok)
        project_ids = json_response['projects'].map { |p| p['id'] }
        expect(project_ids).to include(user_project.id, public_project.id)
        expect(project_ids).not_to include(private_project.id)
      end
    end

    context 'as admin' do
      before { request.headers.merge!(authenticated_headers(admin)) }

      it 'returns all projects' do
        get :index

        expect(response).to have_http_status(:ok)
        expect(json_response['projects'].length).to eq(3)
      end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
        get :index

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST #create' do
    before { request.headers.merge!(authenticated_headers(user)) }

    context 'with valid parameters' do
      let(:valid_params) do
        {
          project: {
            name: 'New Project',
            description: 'Project description',
            visibility: 'shared'
          }
        }
      end

      it 'creates a new project' do
        expect {
          post :create, params: valid_params
        }.to change(Project, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response['project']['name']).to eq('New Project')
        expect(json_response['project']['user_id']).to eq(user.id)
      end
    end

    context 'with invalid parameters' do
      it 'returns validation errors' do
        post :create, params: { project: { name: '' } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']).to eq('Project creation failed')
      end
    end
  end

  describe 'GET #show' do
    let(:project) { create(:project, user: user) }

    context 'with access to project' do
      before { request.headers.merge!(authenticated_headers(user)) }

      it 'returns project details with tasks' do
        task = create(:task, project: project, user: user)
        get :show, params: { id: project.id }

        expect(response).to have_http_status(:ok)
        expect(json_response['project']['id']).to eq(project.id)
        expect(json_response['project']['tasks']).to be_present
        expect(json_response['project']['tasks'].first['id']).to eq(task.id)
      end
    end

    context 'without access to project' do
      before { request.headers.merge!(authenticated_headers(other_user)) }

      it 'returns unauthorized' do
        get :show, params: { id: project.id }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PUT #update' do
    let(:project) { create(:project, user: user) }

    context 'as project owner' do
      before { request.headers.merge!(authenticated_headers(user)) }

      it 'updates the project' do
        put :update, params: {
          id: project.id,
          project: { name: 'Updated Name' }
        }

        expect(response).to have_http_status(:ok)
        expect(json_response['project']['name']).to eq('Updated Name')
        expect(project.reload.name).to eq('Updated Name')
      end
    end

    context 'as non-owner' do
      before { request.headers.merge!(authenticated_headers(other_user)) }

      it 'returns unauthorized' do
        put :update, params: {
          id: project.id,
          project: { name: 'Updated Name' }
        }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:project) { create(:project, user: user) }

    context 'as admin' do
      before { request.headers.merge!(authenticated_headers(admin)) }

      it 'deletes the project' do
        project # create the project
        expect {
          delete :destroy, params: { id: project.id }
        }.to change(Project, :count).by(-1)

        expect(response).to have_http_status(:ok)
        expect(json_response['message']).to eq('Project deleted successfully')
      end
    end

    context 'as regular user' do
      before { request.headers.merge!(authenticated_headers(user)) }

      it 'returns unauthorized' do
        delete :destroy, params: { id: project.id }

        expect(response).to have_http_status(:unauthorized)
        expect(json_response['error']).to eq('Only admins can delete projects')
      end
    end
  end

  describe 'GET #export_tasks' do
    let(:project) { create(:project, user: user) }

    before do
      request.headers.merge!(authenticated_headers(user))
      create(:task, project: project, user: user, title: 'Test Task')
    end

    it 'exports tasks as CSV' do
      get :export_tasks, params: { id: project.id }

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include('text/csv')
      expect(response.body).to include('Test Task')
      expect(response.headers['Content-Disposition']).to include('attachment')
    end
  end
end
