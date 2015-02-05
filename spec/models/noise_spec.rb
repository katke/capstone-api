require 'rails_helper'

describe Noise do
  let!(:in_range_noises) { [create(:noise), create(:noise, lat: 47.901, lon: -122.9, decibel: 100)] }
  let!(:out_of_range_noise) { create(:noise, lat: 47.904, lon: -122.904) }

  describe "#get_score" do

    it "returns a letter score" do
      result = Noise.get_score(47.9, -122.9)
      expect(result).to match(/[A-F]/)
    end

    it "returns a score of F" do
      result = Noise.get_score(47.9, -122.9)
      expect(result).to eq "F"
    end

    it "return a score of A" do
      result = Noise.get_score(42.8, -122.1)
      expect(result).to eq "A"
    end
  end

  describe "#nearby_noises" do

    it "returns nearby locations" do
      result = Noise.nearby_noises(47.9, -122.9)
      expect(result).to eq(in_range_noises)
    end

    it "does not include location that is .004 degrees away" do
      result = Noise.nearby_noises(47.9, -122.9)
      expect(result).not_to eq(:out_of_range_noise)
    end
  end

  describe "#get_decibel_total" do

    it "returns the total number of decibels" do
      result = Noise.get_decibel_total(47.9, -122.9, in_range_noises)
      expect(result).to eq 169.6537540166278
    end
  end
end
