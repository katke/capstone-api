require 'rails_helper'

describe Noise do
  # Can't remember—what is happening in the first create(:noise)
  let!(:in_range_noises) { [create(:noise, lat: 47.9, lon: -122.9, decibel: 600), create(:noise)] }
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
      let!(:sampleNoise) { create(:noise, lat: 25, lon: 25, decibel: 450) }

      it "returns a score of E" do
        result = Noise.get_score(25, 25)
        expect(result[:score]).to eq "E"
      end
    end

    context "D Score" do
      let!(:sampleNoise) { create(:noise, lat: 25, lon: 25, decibel: 350) }

      it "returns a score of D" do
        result = Noise.get_score(25, 25)
        expect(result[:score]).to eq "D"
      end
    end

    context "C Score" do
      let!(:sampleNoise) { create(:noise, lat: 25, lon: 25, decibel: 210) }

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
      create(:noise, noise_type: "transit", description: "Bus Stop - 4th Ave"),
      create(:noise, noise_type: "transit", description: "Bus Stop - 4th Ave"),
      create(:noise, noise_type: "transit", description: "Bus Stop - 5th Ave"),
      create(:noise, noise_type: "freeway", description: "005"),
      create(:noise, noise_type: "freeway", description: "005"),
      create(:noise, noise_type: "freeway", description: "099"),
      create(:noise, noise_type: "construction", description: "foobar"),
      create(:noise, noise_type: "construction", description: "dinobaz")
    ] }
    let!(:result) { Noise.group_noises(array) }

    it "groups transit" do
      all_bus_stops = result.find_all { |i| i[:noise_type].match(/transit/i) }
      expect(all_bus_stops.length).to eq(1)
    end

    it "groups freeways" do
      all_freeways = result.find_all { |i| i[:noise_type].match(/freeway/i) }
      expect(all_freeways.length).to eq(1)
    end

    it "formats as expected" do
      finished_array = [
        {:noise_type=>"3 Transit Stops", :icon=>"road", :details=>nil},
        {:noise_type=>"2 Construction Sites", :icon=>"wrench", :details=>["Foobar", "Dinobaz"]},
        {:noise_type=>"2 Freeways", :icon=>"road", :details=>nil}
      ]
      expect(result).to eq(finished_array)
    end
  end

  describe "#get_descriptive_name" do

    it "returns singular freeway name" do
      result = Noise.get_descriptive_name('freeway', 1)
      expect(result).to eq("1 Freeway")
    end

    it "returns plural freeway name" do
      result = Noise.get_descriptive_name('freeway', 2)
      expect(result).to eq("2 Freeways")
    end

    it "returns singular transit name" do
      result = Noise.get_descriptive_name('transit', 1)
      expect(result).to eq("1 Transit Stop")
    end

    it "returns plural transit name" do
      result = Noise.get_descriptive_name('transit', 2)
      expect(result).to eq("2 Transit Stops")
    end
  end

  describe "#format_description" do

    it "returns formatted description" do
      result = Noise.format_description("NOISE - DISTURBANCE (PARTY, ETC)")
      expect(result).to eq("Noise - disturbance (party, etc)")
    end
  end

  describe "#get_icon" do

    it "returns associated icon" do
      result = Noise.get_icon("freeway")
      expect(result).to eq("road")
    end
  end

  describe "#get_decibel_total" do

    it "returns the total number of decibels" do
      result = Noise.get_decibel_total(47.9, -122.9, in_range_noises)
      expect(result).to eq 669.861033988969
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

  describe "#get_coordinates" do

    context "valid request" do
      let!(:result) { Noise.get_coordinates("500 Union St") }

      it "returns coordinates for request" do
        expect(result).to eq({ "lat" => 47.6099983, "lng" => -122.3343625 })
      end
    end

    context "invalid request" do
      it "throws appropriate error if no address found" do
        expect { Noise.get_coordinates("jawogijawovmnwauwu") }.to raise_error
      end

      it "throws appropriate error if address outside of Seattle" do
        expect { Noise.get_coordinates("77 Massachusetts Avenue, Boston, MA") }.to raise_error
      end
    end
  end
end
