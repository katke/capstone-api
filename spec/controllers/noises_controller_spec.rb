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
    it "is successful" do
      get :score
      expect(response.status).to eq 200
    end

    it "accepts two arguments" do
      get :score, {"latitude" => '-122.9', "longitude" => '47.9'}
      expect(assigns(:latitude)).to eq('-122.9')
    end

  end


end
