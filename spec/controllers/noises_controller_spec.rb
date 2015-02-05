require 'rails_helper'

RSpec.describe NoisesController, :type => :controller do
  render_views

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

    it "checks that noises render correctly" do
      @expected = {
        :noise_type => "foo",
        :decibel => 10,
        :reach => 100,
        :lat => 42.89876,
        :lon => -122.87973,
        :description => "blah blah",
        :seasonal => true
      }
      noise = Noise.create(@expected)
      get :index
      expect(JSON.parse(response.body)[0]["decibel"]).to eq @expected[:decibel]
    end

  end

  describe "GET #score" do
    let!(:in_range_noises) { [create(:noise), create(:noise, lat: 47.901, lon: -122.9, decibel: 100)] }
    let!(:params) { {"latitude" => '47.9', "longitude" => '-122.9'} }

    context "valid coordinates" do
      before(:example) do
        get :score, params, :format => :json
      end

      it "is successful" do
        expect(response.status).to eq 200
      end

      it "accepts two arguments" do
        expect(assigns(:latitude)).to eq(47.9)
        expect(assigns(:longitude)).to eq(-122.9)
      end

      it "returns a letter grade" do
        expect(assigns(:grade)).to eq "F"
      end

      it "returns array of nearby locations" do
        expect(assigns(:nearby_noises)).to eq in_range_noises
      end
    end

    context "invalid coordiates" do
      it "is not successful" do
        get :score, {"latitude" => nil, "longitude" => nil}
        expect(response.status).to eq 400
      end
    end
  end
end
