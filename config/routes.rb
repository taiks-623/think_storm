Rails.application.routes.draw do
  get "brainstorms/index"
  get "brainstorms/new"
  get "brainstorms/show"
  get "pages/home"
  get "terms", to: "pages#terms"
  get "privacy", to: "pages#privacy"
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks",
    registrations: "users/registrations"
  }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  root "pages#home"

  # ログイン後のダッシュボード
  get "dashboard", to: "brainstorms#index", as: :dashboard
  get "dashboard/search_suggestions", to: "brainstorms#search_suggestions", as: :search_suggestions
  
  # ブレストのCRUD
  resources :brainstorms do
    resources :ideas, only: [:create, :edit, :update, :destroy] do
      post 'generate', on: :collection
      resources :tags, only: [:create, :destroy]

      resource :conversation, only: [:create, :show]
    end

    patch 'ideas/:id/update_group', to: 'idea_groups#update_group', as: 'update_group_idea'

    resources :groups, only: [:create, :update, :destroy] do
      post 'cluster', on: :collection
      delete 'reset_clustering', on: :collection
    end
  end

  # ユーザー設定
  resource :profile, only: [:show, :edit, :update]
  delete "profile/cancel", to: "profiles#cancel", as: :cancel_profile

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
