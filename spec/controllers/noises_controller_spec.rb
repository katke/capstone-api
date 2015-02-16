require 'rails_helper'

RSpec.describe NoisesController, :type => :controller do
  render_views

  describe "GET #index" do
    it "is successful" do
      get :index
      expect(response.status).to eq 200
    end

    it "assigns @noises" do
      Noise.create
      number_of_noises = Noise.count
      get :index
      expect(assigns(:noises).length).to eq Noise.count
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
      expect(JSON.parse(response.body)[0]["noise_type"]).to eq @expected[:noise_type]
    end

  end

  describe "GET #score" do
    let!(:in_range_noises) { [create(:noise, lat: 47.5, lon: -122.451, decibel: 70), create(:noise, lat: 47.501, lon: -122.45, decibel: 100)] }
    let!(:params) { {"latitude" => '47.5', "longitude" => '-122.45'} }

    context "valid coordinates" do
      before(:example) do
        get :score, params, :format => :json
      end

      it "is successful" do
        expect(response.status).to eq 200
      end

      it "accepts two arguments" do
        expect(assigns(:latitude)).to eq(47.5)
        expect(assigns(:longitude)).to eq(-122.45)
      end

      it "returns a letter grade" do
        expect(assigns(:grade)).to eq "B"
      end

      it "returns array of nearby locations" do
        final_response = [{noise_type: "1 Transit Stop", icon: "road", details: nil}]
        expect(assigns(:nearby_noises)).to eq final_response
      end
    end

    context "outside Seattle coordinates" do
      it "is not successful" do
        get :score, {"latitude" => 25, "longitude" => 25}
        expect(response.status).to eq 400
      end
    end

    context "invalid coordinates" do
      it "is not successful" do
        get :score, {"latitude" => nil, "longitude" => nil}
        expect(response.status).to eq 400
      end
    end
  end

  describe "GET #coordinates" do

    let!(:sample_address) { "500 Union St" }

    context "valid user" do
      before(:example) {
        request.env["REMOTE_ADDR"] = "127.0.0.1"
      }

      context "valid request" do
        let!(:response) { get :coordinates, { "address" => sample_address } }

        it "is successful" do
          expect(response.status).to eq 200
        end

        it "assigns @address" do
          expect(assigns(:address)).to eq(sample_address)
        end

        it "returns coordinates" do
          expect(assigns(:coordinates)).to eq({ "lat" => 47.6099983, "lng" => -122.3343625 })
        end
      end

      context "invalid request" do
        it "returns 400 if Address Invaild" do
          get :coordinates, { "address" => "jawogijawovmnwauwu" }
          expect(response.status).to eq 400
        end
      end
    end

    context "invalid user" do

      it "is unsuccessful" do
        get :coordinates, { "address" => sample_address }
        expect(response.status).to eq 401
      end
    end
  end
end
