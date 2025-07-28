Rails.application.routes.draw do
  get "restaurants/new"
  get "restaurants/create"
  apipie
  devise_for :users
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
  resources :restaurants, only: [:index, :new, :create, :show, :edit, :update]

  # # Creating account
  # get "/signup", to: "users#new", as: "sign_up"
  # post "/signup", to: 'users#create', as: 'create_user'

  # # Logging in/out - Handling sessions
  # get '/sign_in', to: 'sessions#new', as: 'sign_in'
  # post '/sign_in', to: 'sessions#create', as: 'sign_in_submit'
  # delete '/sign_out', to: 'sessions#destroy', as: 'sign_out'
end
