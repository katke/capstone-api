require 'json'
require 'date'

#//////////////////////////////////////#
#//  Methods For Seeding             //#
#//////////////////////////////////////#

## Add Stationary Locations!
def get_json(file)
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

def stationary_locations(noise_type, file, decibel, reach, seasonal)
  puts "\n[Starting #{noise_type}]"
  results = get_json(file)

  results.each do |r|
    common_name = r["common_name"]
    common_name = common_name.strip
    noise = Noise.create(
      description: common_name,
      noise_type: noise_type,
      lat: r["latitude"],
      lon: r["longitude"],
      decibel: decibel,
      reach: reach,
      seasonal: seasonal
    )

    if noise.noise_type == "trolley"
      noise.update(description: "Trolley - #{common_name}", noise_type: "transit")
    end

    print "."
  end

  puts "\n#{noise_type} Imported"
end

# GeoJSON Extracted from GIS
def gis_stationary_locations(noise_type, file, decibel, reach, seasonal)
  puts "\n[Starting #{noise_type}]"
  results = get_json(file)["features"]

  results.each do |r|
    noise = Noise.create(
      description: r["properties"]["NAME"],
      noise_type: noise_type,
      lat: r["geometry"]["coordinates"][1],
      lon: r["geometry"]["coordinates"][0],
      decibel: decibel,
      reach: reach,
      seasonal: seasonal
    )

    if noise.noise_type == "busStop"
      noise.update(description: "Bus Stop - #{r['properties']['NAME']}", noise_type: "transit")
    elsif noise.noise_type == "transitCenter"
      noise.update(description: "Transit Center - #{r['properties']['NAME']}", noise_type: "transit")
    end

    print "."
  end

  puts "\n#{noise_type} Imported"
end

# GeoJSON Lines from GIS
def gis_lines(noise_type, file, decibel, reach, name)
  puts "\n[Starting #{noise_type}]"
  results = get_json(file)["features"]

  results.each do |r|
    if r["geometry"]
      r["geometry"]["coordinates"].each do |f|
        lat = f[1]
        lon = f[0]

        if Noise.in_seattle?(lat, lon)
          Noise.create(
            description: r["properties"][name],
            noise_type: noise_type,
            lat: lat,
            lon: lon,
            decibel: decibel,
            reach: reach,
            seasonal: false
          )
          print "."
        end
      end
    end
  end

  puts "\n#{noise_type} Imported"
end

# Creating Perishable Noise Type
def perishable_locations(noise_type, file, decibel, reach, seasonal)
  puts "\n[Starting #{noise_type}]"
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
          seasonal: seasonal
        )

        Perishable.create(
          noise_id: noise.id,
          start: r["issue_date"],
          end: r["expiration_date"]
        )

        print "."
      end
    end
  end

  puts "\n#{noise_type} Imported"

end

def noise_complaints(noise_type, file, decibel, reach, seasonal)
  puts "\n[Starting #{noise_type}]"
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
        seasonal: seasonal
        )
      unless noise.description
        noise.update(description: "Noise Disturbance")
      end
    end
    print "."
  end
  puts "\n#{noise_type} Imported"
end


#//////////////////////////////////////#
#// Actual Seeding                   //#
#//////////////////////////////////////#

## Clear Out Current Database!
puts "Clearing Database..."
Noise.destroy_all
Perishable.destroy_all

# Stationary Noise Hashes!
regular_stationary = {
  "fireStation" => { file: "znfv-apni", decibel: 125, reach: 4593, seasonal: false },
  "school" => { file: "pmap-kbvr", decibel: 70, reach: 10, seasonal: true },
  "college" => { file: "qawk-qmwr", decibel: 74, reach: 16, seasonal: true },
  "trolley" => { file: "4qvq-uf9z", decibel: 65, reach: 6, seasonal: false },
  "hospital" => { file: "points/custom/seattle-er", decibel: 125, reach: 4593, seasonal: false },
  "bar" => { file: "points/custom/bar_geolocation", decibel: 70, reach: 10, seasonal: false },
  "heliportOrAirport" => { file: "points/custom/heliports", decibel: 100, reach: 3117, seasonal: false },
  "stadium" => { file: "points/custom/stadiums", decibel: 100, reach: 263, seasonal: true }
}

gis_stationary = {
  "policeStation" => { file: "points/gis/police", decibel: 125, reach: 4593, seasonal: false },
  "busStop" => { file: "points/gis/bus_stops", decibel: 74, reach: 16, seasonal: false },
  "dump" => { file: "points/gis/solid_waste", decibel: 93, reach: 151, seasonal: false },
  "transitCenter" => { file: "points/gis/transit_centers", decibel: 74, reach: 16, seasonal: false }
}

stationary_perishable = {
  "construction" => { file: "9yds-qdb3", decibel: 93, reach: 151, seasonal: false },
  "demolition" => { file: "j6ng-5q2r", decibel: 100, reach: 263, seasonal: false }
}

stationary_noise_complaints = {
  "noiseComplaints" => { file: "3k2p-39jp", decibel: 65, reach: 60, seasonal: false }
}

gis_roads = {
  "freeway" => { file: "lines/freeway", decibel: 80, reach: 30, description: "StateRoute" },
  # "railroad" => { file: "lines/railroads", decibel: 80, reach: 30, description: "Name"} ## Data seems inacurrate?
}

# Create Stationary Noises!
regular_stationary.each do |k, v|
  stationary_locations(k, v[:file], v[:decibel], v[:reach], v[:seasonal])
end

stationary_perishable.each do |k, v|
  perishable_locations(k, v[:file], v[:decibel], v[:reach], v[:seasonal])
end

stationary_noise_complaints.each do |k, v|
  noise_complaints(k, v[:file], v[:decibel], v[:reach], v[:seasonal])
end

gis_stationary.each do |k, v|
  gis_stationary_locations(k, v[:file], v[:decibel], v[:reach], v[:seasonal])
end

gis_roads.each do |k, v|
  gis_lines(k, v[:file], v[:decibel], v[:reach], v[:description])
end

puts "Seeding Complete! #{Noise.count} Noises in Database! :)"
