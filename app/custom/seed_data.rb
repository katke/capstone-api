require 'json'
require 'date'

class SeedData
  # Command to Run Imports
  def self.import_data(noises_to_create)
    noises_to_create.each do |k, v|
      case v[:file_type]
      when "regular_stationary"
        stationary_locations(k, v)
      when "gis_stationary"
        gis_stationary_locations(k, v)
      when "stationary_perishable"
        perishable_locations(k, v)
      when "stationary_noise_complaints"
        noise_complaints(k, v)
      when "gis_roads"
        gis_lines(k, v)
      else
        puts "?"
      end
    end
  end

  def self.status_dot
    print "."
  end

  # Obtain Data
  def self.get_json(file)
    if file.match(/\//)
      file_string = File.read("./lib/assets/#{file}.json")
      JSON.parse(file_string)
    elsif file == "j6ng-5q2r"
      HTTParty.get("https://data.seattle.gov/resource/#{file}.json?status=permit%20issued").parsed_response
    elsif file == "9yds-qdb3"
      HTTParty.get("https://data.seattle.gov/resource/#{file}.json?status=permit%20issued&action_type=new").parsed_response
    elsif file == "3k2p-39jp"
      HTTParty.get("https://data.seattle.gov/resource/#{file}.json?event_clearance_description=noise%20disturbance&$limit=1000&$order=event_clearance_date%20DESC")
    else
      HTTParty.get("https://data.seattle.gov/resource/#{file}.json").parsed_response
    end
  end

  def self.create_noise(description, noise_type, lat, lon, hash)
    return Noise.create(
      description: description,
      noise_type: noise_type,
      lat: lat,
      lon: lon,
      decibel: hash[:decibel],
      reach: hash[:reach],
      seasonal: hash[:seasonal],
      display_reach: hash[:display_reach]
    )
  end

  # Add Stationary Non-GIS Locations
  def self.stationary_locations(noise_type, hash)
    puts "\n[Starting #{noise_type}]"
    results = get_json(hash[:file])

    results.each do |r|
      description = r["common_name"].strip
      lat = r["latitude"]
      lon = r["longitude"]

      noise = create_noise(description, noise_type, lat, lon, hash)
      update_description(noise, r)
      update_display_reach(noise)
      status_dot
    end
    puts "\n#{noise_type} Imported"
  end

  # Add Stationary GIS Locations
  def self.gis_stationary_locations(noise_type, hash)
    puts "\n[Starting #{noise_type}]"
    results = get_json(hash[:file])["features"]

    results.each do |r|
      description = r["properties"]["NAME"]
      lat = r["geometry"]["coordinates"][1]
      lon = r["geometry"]["coordinates"][0]

      noise = create_noise(description, noise_type, lat, lon, hash)
      update_description(noise, r)
      status_dot
    end
    puts "\n#{noise_type} Imported"
  end

  # Adding Non-Stationary GIS Points
  def self.gis_lines(noise_type, hash)
    puts "\n[Starting #{noise_type}]"
    results = get_json(hash[:file])["features"]

    results.each { |r| turn_line_into_points(r, noise_type, hash) }
    puts "\n#{noise_type} Imported"
  end

  def self.turn_line_into_points(r, noise_type, hash)
    r["geometry"]["coordinates"].each do |f|
      lat = f[1]
      lon = f[0]

      if Noise.in_seattle?(lat, lon)
        name = hash[:description]
        description = r["properties"][name]

        create_noise(description, noise_type, lat, lon, hash)
        status_dot
      end
    end
  end

  # Add Perishable Noises
  def self.perishable_locations(noise_type, hash)
    puts "\n[Starting #{noise_type}]"
    results = get_json(hash[:file])

    results.each do |r|
      if r["expiration_date"] && permit_active?(r["expiration_date"])
        description = r["description"]
        lat = r["latitude"]
        lon = r["longitude"]

        noise = create_noise(description, noise_type, lat, lon, hash)
        create_perishable(noise.id, r["issue_date"], r["expiration_date"])
        status_dot
      end
    end
    puts "\n#{noise_type} Imported"
  end

  def self.permit_active?(date)
    result = Date.today <=> date.to_date
    result == -1 ? true : false
  end

  def self.create_perishable(id, issue_date, expiration_date)
    Perishable.create(noise_id: id, start: issue_date, end: expiration_date)
  end

  # Add Noise Complaints
  def self.noise_complaints(noise_type, hash)
    puts "\n[Starting #{noise_type}]"
    results = get_json(hash[:file])

    results.each do |r|
      description = r["initial_type_description"]

      unless /WEAPON/i.match(description) || /SHOTS/i.match(description) || /ASLT/i.match(description) || /HARAS/i.match(description)
        description ? description = description.capitalize : description = "Unspecified Noise Disturbance"
        lat = r["latitude"]
        lon = r["longitude"]
        
        noise = create_noise(description, noise_type, lat, lon, hash)
        status_dot
      end
    end
    puts "\n#{noise_type} Imported"
  end

  # Tidy Descriptions
  def self.update_description(noise, r)
    type = noise.noise_type
    if type == "trolley" || type == "busStop" || type == "transitCenter"
      update_transit(noise, r)
    elsif type == "bar"
      noise.update(description: r["common_name"].strip.capitalize)
    end
  end

  def self.update_transit(noise, r)
    if noise.noise_type == "trolley"
      description = "Trolley - #{r['common_name'].strip}"
    elsif noise.noise_type == "busStop"
      description = "Bus Stop - #{r['properties']['NAME']}"
    elsif noise.noise_type == "transitCenter"
      description = "Transit Center - #{r['properties']['NAME']}"
    end

    noise.update(description: description, noise_type: "transit")
  end

  # Tidy Display Reaches
  def self.update_display_reach(noise)
    reach_hash = {
      "University Of Washington" => 55,
      "Seattle University" => 30,
      "King County International Airport (Boeing Field)" => 100,
      "Seattle-Tacoma International Airport" => 150
    }

    name = noise.description
    if reach_hash.keys.include?(name)
      noise.update(display_reach: reach_hash[name])
    end
  end
end
