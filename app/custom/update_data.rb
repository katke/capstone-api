class UpdateData

  def self.remove_existing_records
    noises = Noise.where("noise_type = ? OR noise_type = ? OR noise_type = ?", "construction", "demolition", "noiseComplaints")
    noises.destroy_all
    Perishable.destroy_all
  end

  def self.get_json(file)
    # demolition data
    if file == "j6ng-5q2r"
      HTTParty.get("https://data.seattle.gov/resource/#{file}.json?status=permit%20issued").parsed_response
    # construction data
    elsif file == "9yds-qdb3"
      HTTParty.get("https://data.seattle.gov/resource/#{file}.json?status=permit%20issued&action_type=new").parsed_response
    # Most recent 1,000 911 noise complaints
    elsif file == "3k2p-39jp"
      HTTParty.get("https://data.seattle.gov/resource/#{file}.json?event_clearance_description=noise%20disturbance&$limit=1000&$order=event_clearance_date%20DESC")
    end
  end

  def self.perishable_locations(noise_type, file, decibel, reach, seasonal, display_reach)
    # Call API for Construction/Demolition
    results = get_json(file)

    results.each do |r|
      # Checks for existing expiration date
      if r["expiration_date"]
        # Check that permit is active
        result = Date.today <=> r["expiration_date"].to_date
        if result == -1
          noise = Noise.create(
            description: r["description"],
            noise_type: noise_type,
            lat: r["latitude"],
            lon: r["longitude"],
            decibel: decibel,
            reach: reach,
            seasonal: seasonal,
            display_reach: display_reach
          )

          Perishable.create(
            noise_id: noise.id,
            start: r["issue_date"],
            end: r["expiration_date"]
          )
        end
      end
    end
    puts "\n#{noise_type} Imported"
  end

  def self.noise_complaints(noise_type, file, decibel, reach, seasonal, display_reach)
    # Call API for Noise Complaints
    results = get_json(file)

    results.each do |r|
      unless /WEAPON/i.match(r["initial_type_description"]) || /SHOTS/i.match(r["initial_type_description"]) || /ASLT/i.match(r["initial_type_description"]) || /HARAS/i.match(r["initial_type_description"])
        noise = Noise.create(
          description: r["initial_type_description"],
          noise_type: noise_type,
          lat: r["latitude"],
          lon: r["longitude"],
          decibel: decibel,
          reach: reach,
          seasonal: seasonal,
          display_reach: display_reach
          )
        unless noise.description
          noise.update(description: "Noise Disturbance")
        end
      end
    end
    puts "\n#{noise_type} Imported"
  end

  def self.repull_data
    # Setup noise sets to update
    noises_to_update = {
    "construction" =>      { file_type: "stationary_perishable", file: "9yds-qdb3", decibel: 93, reach: 151, seasonal: false, display_reach: 6 },
    "demolition" =>        { file_type: "stationary_perishable", file: "j6ng-5q2r", decibel: 100, reach: 263, seasonal: false, display_reach: 9 },
    "noiseComplaints" =>   { file_type: "stationary_noise_complaints", file: "3k2p-39jp", decibel: 65, reach: 60, seasonal: false, display_reach: 2 }
    }

    # Recreate data
    noises_to_update.each do |k, v|
      case v[:file_type]
      when "stationary_perishable"
        perishable_locations(k, v[:file], v[:decibel], v[:reach], v[:seasonal], v[:display_reach])
      when "stationary_noise_complaints"
        noise_complaints(k, v[:file], v[:decibel], v[:reach], v[:seasonal], v[:display_reach])
      end
    end
  end

end
