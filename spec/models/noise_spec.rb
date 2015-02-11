require 'rails_helper'

describe Noise do
  let!(:in_range_noises) { [create(:noise), create(:noise, lat: 47.901, lon: -122.9, decibel: 100)] }
  let!(:out_of_range_noise) { create(:noise, lat: 47.904, lon: -122.904) }

  describe "#get_score" do

    context "F Score" do
      let!(:result) { Noise.get_score(47.9, -122.9) }

      it "returns a letter score" do
        expect(result[:score]).to match(/[A-F]/)
      end

      it "returns a score of F" do
        expect(result[:score]).to eq "F"
      end
    end

    context "E Score" do
      let!(:sampleNoise) { create(:noise, lat: 25, lon: 25, decibel: 95) }

      it "returns a score of E" do
        result = Noise.get_score(25, 25)
        expect(result[:score]).to eq "E"
      end
    end

    context "D Score" do
      let!(:sampleNoise) { create(:noise, lat: 25, lon: 25, decibel: 85) }

      it "returns a score of E" do
        result = Noise.get_score(25, 25)
        expect(result[:score]).to eq "D"
      end
    end

    context "C Score" do
      let!(:sampleNoise) { create(:noise, lat: 25, lon: 25, decibel: 75) }

      it "returns a score of E" do
        result = Noise.get_score(25, 25)
        expect(result[:score]).to eq "C"
      end
    end

    context "B Score" do
      let!(:sampleNoise) { create(:noise, lat: 25, lon: 25, decibel: 65) }

      it "returns a score of E" do
        result = Noise.get_score(25, 25)
        expect(result[:score]).to eq "B"
      end
    end

    context "A Score" do
      let!(:result) { Noise.get_score(42.8, -122.1) }

      it "return a score of A" do
        expect(result[:score]).to eq "A"
      end
    end
  end

  describe "#nearby_noises" do
    let!(:result) { Noise.nearby_noises(47.9, -122.9) }

    it "returns nearby locations" do
      expect(result).to eq(in_range_noises)
    end

    it "does not include location that is .004 degrees away" do
      expect(result).not_to eq(:out_of_range_noise)
    end
  end

  describe "#group_noises" do
    let!(:array) { [
      create(:noise, noise_type: "busStop", description: "4th Ave"),
      create(:noise, noise_type: "busStop", description: "4th Ave"),
      create(:noise, noise_type: "busStop", description: "5th Ave"),
      create(:noise, noise_type: "freeway", description: "005"),
      create(:noise, noise_type: "freeway", description: "005"),
      create(:noise, noise_type: "freeway", description: "099"),
      create(:noise, noise_type: "construction", description: "foobar"),
      create(:noise, noise_type: "construction", description: "dinobaz")
    ] }
    let!(:result) { Noise.group_noises(array) }

    it "groups busStops by street address" do
      all_bus_stops = result.find_all { |i| i[:noise_type] == "busStop" }
      expect(all_bus_stops.length).to eq(2)
    end

    it "groups freeways by freeway number" do
      all_freeways = result.find_all { |i| i[:noise_type] == "freeway" }
      expect(all_freeways.length).to eq(2)
    end

    it "formats as expected" do
      finished_array = [
        {:noise_type=>"busStop", :description=>"1 Bus Stop(s) on 5th Ave"},
        {:noise_type=>"freeway", :description=>"1 Nearby Freeway(s)"},
        {:noise_type=>"busStop", :description=>"2 Bus Stop(s) on 4th Ave"},
        {:noise_type=>"construction", :description=>"foobar"},
        {:noise_type=>"construction", :description=>"dinobaz"},
        {:noise_type=>"freeway", :description=>"2 Nearby Freeway(s)"}
      ]
      expect(result).to eq(finished_array)
    end
  end

  describe "#get_decibel_total" do

    it "returns the total number of decibels" do
      result = Noise.get_decibel_total(47.9, -122.9, in_range_noises)
      expect(result).to eq 169.6537540166278
    end
  end

  describe "#in_seattle?" do

    it "returns true for coordinates in Seattle" do
      result = Noise.in_seattle?(47.609998, -122.334362)
      expect(result).to eq true
    end

    it "returns false for coordinates outside of Seattle" do
      result = Noise.in_seattle?(25, 25)
      expect(result).to eq false
    end

    it "returns false for invalid coordinates" do
      result = Noise.in_seattle?(["foo"], ["bar"])
      expect(result).to eq false
    end
  end
end
