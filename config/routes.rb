Rails.application.routes.draw do
  get "brainstorms/index"
  get "brainstorms/new"
  get "brainstorms/show"
  get "pages/home"
  get "terms", to: "pages#terms"
  get "privacy", to: "pages#privacy"
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks"
  }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  root "pages#home"

  # ログイン後のダッシュボード
  get "dashboard", to: "brainstorms#index", as: :dashboard
  
  # ブレストのCRUD
  resources :brainstorms do
    resources :ideas, only: [:create, :edit, :update, :destroy] do
      post 'generate', on: :collection
    end

    patch 'ideas/:id/update_group', to: 'idea_groups#update_group', as: 'update_group_idea'

    resources :groups, only: [:create, :update, :destroy] do
      post 'cluster', on: :collection
      delete 'reset_clustering', on: :collection
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
