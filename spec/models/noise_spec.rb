require 'rails_helper'

describe Noise do

  describe "#get_score" do

    it "returns a letter score" do
      result = Noise.get_score(47.9, -122.9)
      expect(result).to match(/[A-F]/)
    end
  end

  describe "#nearby_noises" do

    let!(:noise1) { Noise.create(lat: 47.902,lon: -122.9) }
    let!(:noise2) { Noise.create(lat: 48,lon: -122.9) }

    it "returns nearby locations" do
      result = Noise.nearby_noises(47.9, -122.9)
      expect(result).to eq([noise1])
    end
  end
end
