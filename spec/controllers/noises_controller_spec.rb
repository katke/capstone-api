require 'rails_helper'

RSpec.describe NoisesController, :type => :controller do

  describe "GET #index" do
    it "is successful" do
      get :index
      expect(response.status).to eq 200
    end

    it "assigns @noises" do
      number_of_noises = Noise.count
      get :index
      expect(assigns(:noises).count).to eq number_of_noises 
    end
  end


end
