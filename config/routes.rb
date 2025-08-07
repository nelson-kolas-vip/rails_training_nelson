Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  get "reservations/index"
  get "reservations/new"
  get "restaurants/new"
  get "restaurants/create"
  apipie

  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }
  # Homepage
  root to: redirect("/homepage")
  get "homepage", to: "homepage#index"

  # Counter
  get "count", to: "counter#show"
  post "count/increment", to: "counter#increment", as: "increment_count"
  get "count/reset", to: "counter#reset", as: "reset_count"

  # Part of OS-65: APIPIE
  # mount Apipie::Engine => '/apipie'
  namespace :api do
    namespace :v1 do
      resources :users, only: [:index, :create, :show, :update, :destroy]
    end
  end
  resource :avatar, only: [:edit, :update, :destroy]

  resources :feedbacks, only: [:index, :new, :create]

  resources :restaurants, only: [:index, :new, :create, :show, :edit, :update]
  resources :restaurants do
    resources :tables, only: [:index, :new, :create, :edit, :update, :destroy]
    resources :menus, only: [:index, :new, :create, :edit, :update, :destroy], controller: "menus"
    resources :reservations, only: [:index, :new, :create, :show, :update, :destroy] do
      member do
        patch :accept
        patch :reject
      end
    end
    resources :feedbacks, only: [:index, :new, :create], controller: "feedbacks"
  end

  # # Creating account
  # get "/signup", to: "users#new", as: "sign_up"
  # post "/signup", to: 'users#create', as: 'create_user'

  # # Logging in/out - Handling sessions
  # get '/sign_in', to: 'sessions#new', as: 'sign_in'
  # post '/sign_in', to: 'sessions#create', as: 'sign_in_submit'
  # delete '/sign_out', to: 'sessions#destroy', as: 'sign_out'
end
