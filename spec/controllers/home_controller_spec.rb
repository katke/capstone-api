require 'rails_helper'

RSpec.describe HomeController, :type => :controller do

  describe "GET #index" do
    it "is redirected" do
      get :index
      expect(response.status).to eq 302
    end
  end

end
