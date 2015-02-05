Rails.application.routes.draw do

  defaults format: :json do
    get '/score', to: "noises#score", as: :noise_score
  end

  root 'noises#index'
end
