class UpdateData

  def self.remove_existing_records
    noises = Noise.where("noise_type = ? OR noise_type = ? OR noise_type = ?", "construction", "demolition", "noiseComplaints")
    noises.destroy_all
    Perishable.destroy_all
  end

  def self.repull_data
    # Setup noise sets to update
    noises_to_update = {
    "construction" =>      { file_type: "stationary_perishable", file: "9yds-qdb3", decibel: 93, reach: 151, seasonal: false, display_reach: 6 },
    "demolition" =>        { file_type: "stationary_perishable", file: "j6ng-5q2r", decibel: 100, reach: 263, seasonal: false, display_reach: 9 },
    "noiseComplaints" =>   { file_type: "stationary_noise_complaints", file: "3k2p-39jp", decibel: 65, reach: 60, seasonal: false, display_reach: 2 }
    }

    # Recreate data
    SeedData.import_data(noises_to_update)
  end
end
