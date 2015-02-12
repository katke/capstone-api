Rails.application.routes.draw do

  defaults format: :json do
    get '/noises', to: "noises#index", as: :noises
    get '/score', to: "noises#score", as: :noise_score
  end

  root 'home#index'
end
