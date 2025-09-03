Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # API routes
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      # Authentication
      post 'auth/login', to: 'auth#login'
      post 'auth/register', to: 'auth#register'

      # Users
      resources :users, only: [:index, :show, :update] do
        collection do
          get :me
        end
      end

      # Projects
      resources :projects do
        member do
          get 'export_tasks'
        end

        # Tasks nested under projects
        resources :tasks, except: [:index]

        # Project permissions
        resources :project_permissions, only: [:index, :show, :create, :destroy]

        # Deletion requests
        resources :deletion_requests, only: [:create]
      end

      # Global tasks endpoints
      get 'tasks', to: 'tasks#my_tasks'

      # Admin deletion requests management
      resources :deletion_requests, only: [:index, :show, :update, :destroy] do
        collection do
          get :my_requests
        end
      end
    end
  end

  # Redirect root to API documentation (we can implement this of swagger or postman docs needed)
  root to: redirect('/api/v1')
end
