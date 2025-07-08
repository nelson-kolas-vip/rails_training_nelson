Rails.application.routes.draw do
  # Homepage
  root to: redirect("/homepage")
  get 'homepage', to: 'homepage#index'

  # Counter
  get 'count', to: 'counter#show'
  post 'count/increment', to: 'counter#increment', as: 'increment_count'
  get 'count/reset', to: 'counter#reset', as: 'reset_count'
end
