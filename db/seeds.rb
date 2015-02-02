require 'json'
require 'date'

#//////////////////////////////////////#
#//  Methods For Seeding             //#
#//////////////////////////////////////#

## Add Stationary Locations!
def get_json(file)
  if file.match(/\//)
    file_string = File.read("./lib/assets/points/#{file}.json")
    JSON.parse(file_string)
  elsif file == "9yds-qdb3"
    # Should we also add query to filter for construction type?
    HTTParty.get("https://data.seattle.gov/resource/#{file}.json?status=%27permit%20issued%27").parsed_response
  elsif file == "j6ng-5q2r"
    HTTParty.get("https://data.seattle.gov/resource/#{file}.json?status=%27permit%20issued%27").parsed_response
  else
    HTTParty.get("https://data.seattle.gov/resource/#{file}.json").parsed_response
  end
end

def stationary_locations(noise_type, file, decibel, reach, seasonal)
  results = get_json(file)

  results.each do |r|
    Noise.create(
      description: r["common_name"],
      noise_type: noise_type,
      lat: r["latitude"],
      lon: r["longitude"],
      decibel: decibel,
      reach: reach,
      seasonal: seasonal
    )
    print "."
  end

  puts "\n#{noise_type} Imported"
end

# GeoJSON Extracted from GIS
def gis_stationary_locations(noise_type, file, decibel, reach, seasonal)
  results = get_json(file)["features"]

  results.each do |r|
    Noise.create(
      description: r["properties"]["NAME"],
      noise_type: noise_type,
      lat: r["geometry"]["coordinates"][1],
      lon: r["geometry"]["coordinates"][0],
      decibel: decibel,
      reach: reach,
      seasonal: seasonal
    )
    print "."
  end

  puts "\n#{noise_type} Imported"
end

# Creating Perishable Noise Type
def perishable_locations(noise_type, file, decibel, reach, seasonal)
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


#//////////////////////////////////////#
#// Actual Seeding                   //#
#//////////////////////////////////////#

## Clear Out Current Database!
puts "Clearing Database..."
Noise.destroy_all
Perishable.destroy_all

# Stationary Noise Hashes!
regular_stationary = {
  "Fire Station" => { file: "znfv-apni", decibel: 125, reach: 45932, seasonal: false },
  "School" => { file: "pmap-kbvr", decibel: 70, reach: 104, seasonal: true },
  "College" => { file: "qawk-qmwr", decibel: 70, reach: 104, seasonal: true },
  "Trolley" => { file: "4qvq-uf9z", decibel: 65, reach: 60, seasonal: false },
  "Hospital" => { file: "custom/seattle-er", decibel: 125, reach: 45932, seasonal: false },
  "Bar" => { file: "custom/bar_geolocation", decibel: 70, reach: 104, seasonal: false },
  # "Noise Complaint" => { file: "3k2p-39jp", decibel: 65, reach: 60, seasonal: false }
}

gis_stationary = {
  "Police Station" => { file: "gis/police", decibel: 125, reach: 45932, seasonal: false },
  "Bus Stop" => { file: "gis/bus_stops", decibel: 74, reach: 164, seasonal: false },
  "Dump" => { file: "gis/solid_waste", decibel: 93, reach: 1509, seasonal: false },
  "Transit Center" => { file: "gis/transit_centers", decibel: 74, reach: 164, seasonal: false },
}

stationary_perishable = {
  "Construction" => { file: "9yds-qdb3", decibel: 93, reach: 1509, seasonal: false },
  "Demolition" => { file: "j6ng-5q2r", decibel: 100, reach: 2625, seasonal: false }
}

# Create Stationary Noises!
# regular_stationary.each do |k, v|
#   stationary_locations(k, v[:file], v[:decibel], v[:reach], v[:seasonal])
# end

stationary_perishable.each do |k, v|
  perishable_locations(k, v[:file], v[:decibel], v[:reach], v[:seasonal])
end

# gis_stationary.each do |k, v|
#   gis_stationary_locations(k, v[:file], v[:decibel], v[:reach], v[:seasonal])
# end
