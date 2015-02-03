require 'rails_helper'

describe Noise do

  describe "#get_score" do

    it "returns a letter score" do
      result = Noise.get_score(47.9, -122.9)
      expect(result).to match(/[A-F]/)
    end
  end

  describe "#nearby_noises" do

    let!(:in_range_noises) { [Noise.create(lat: 47.902, lon: -122.9), Noise.create(lat: 47.9, lon: -122.902)] }
    let!(:out_of_range_noise) { Noise.create(lat: 48, lon: -122.9) }


    it "returns nearby locations" do
      result = Noise.nearby_noises(47.9, -122.9)
      expect(result).to eq(in_range_noises)
    end
  end
end
