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
    get 'export_markdown', on: :member
    resources :ideas, only: [:create, :edit, :update, :destroy] do
      post 'generate', on: :collection
      resources :tags, only: [:create, :destroy]
      resource :conversation, only: [:create, :show]
      resources :evaluations, only: [:create, :update]
      resource :vote, only: [:create, :destroy]
      resources :comments, only: [:create, :destroy]
    end

    patch 'ideas/:id/update_group', to: 'idea_groups#update_group', as: 'update_group_idea'

    resources :groups, only: [:create, :update, :destroy] do
      post 'cluster', on: :collection
      delete 'reset_clustering', on: :collection
    end

    resources :evaluation_axes, only: [:create, :update, :destroy]

    member do
      get  :invite
      post :invite, action: :create_invitation
    end
  end

  # ユーザー設定
  # resource :profile, only: [:show, :edit, :update]
  # delete "profile/cancel", to: "profiles#cancel", as: :cancel_profile

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  # 招待リンクからの参加
  get  '/join/:token', to: 'brainstorm_invitations#show', as: :join_brainstorm
  post '/join/:token', to: 'brainstorm_invitations#join', as: :join_brainstorm_confirm

  namespace :users do
    resource :profile, only: [:edit, :update]
    resource :email, only: [:edit, :update]
    resource :account, only: [:show, :destroy]
  end

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
