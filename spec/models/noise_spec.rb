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
    let!(:out_of_range_noise) { Noise.create(lat: 47.904, lon: -122.904) }


    it "returns nearby locations" do
      result = Noise.nearby_noises(47.9, -122.9)
      expect(result).to eq(in_range_noises)
    end

    it "does not include location that is .004 degrees away" do
      result = Noise.nearby_noises(47.9, -122.9)
      expect(result).not_to eq(:out_of_range_noise)
    end

  end
end
