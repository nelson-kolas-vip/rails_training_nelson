Rails.application.routes.draw do
  devise_for :users
  # Homepage
  root to: redirect("/homepage")
  get "homepage", to: "homepage#index"

  # Counter
  get "count", to: "counter#show"
  post "count/increment", to: "counter#increment", as: "increment_count"
  get "count/reset", to: "counter#reset", as: "reset_count"

  # # Creating account
  # get "/signup", to: "users#new", as: "sign_up"
  # post "/signup", to: 'users#create', as: 'create_user'

  # # Logging in/out - Handling sessions
  # get '/sign_in', to: 'sessions#new', as: 'sign_in'
  # post '/sign_in', to: 'sessions#create', as: 'sign_in_submit'
  # delete '/sign_out', to: 'sessions#destroy', as: 'sign_out'
end
