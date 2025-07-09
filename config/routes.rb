Rails.application.routes.draw do
  get "sessions/new"
  get "sessions/create"
  get "sessions/destroy"
  # Homepage
  root to: redirect("/homepage")
  get "homepage", to: "homepage#index"

  # Counter
  get "count", to: "counter#show"
  post "count/increment", to: "counter#increment", as: "increment_count"
  get "count/reset", to: "counter#reset", as: "reset_count"

  # User Authentication
  get "/signup", to: "users#new", as: "signup"
  post "/signup", to: "users#create"

  get "/login", to: "sessions#new", as: "login"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy", as: "logout"
end
