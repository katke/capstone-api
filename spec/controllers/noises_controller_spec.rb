require 'rails_helper'

RSpec.describe NoisesController, :type => :controller do

  describe "GET #index" do
    it "is successful" do
       get :index
       expect(response.status).to eq 200
    end

    # it "renders the :index template" do
    #   get :index
    #   expect(response).to render_template(:index)
    # end
  end


end
