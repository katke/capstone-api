Rails.application.routes.draw do
  get '/score', to: "noises#score", as: :noise_score
  root 'noises#index'

end
