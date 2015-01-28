require 'json'
require 'factual'
#//////////////////////////////////////#
#//  Methods For Seeding             //#
#//////////////////////////////////////#
## Loop To Add Factual Data One Page At a Time
def get_bars
  factual = Factual.new(ENV[FACTUAL_OAUTH_KEY], ENV[FACTUAL_OAUTH_SECRET])
  count = 1
  page_num = 1
  unless count == 0
    rows = factual.table("places-us").filters("category_ids" => {"$includes" => 312}, "locality" => "Seattle").page(page_num, :per => 50).rows
    count = rows.count
    count.times do
      rows.each do |bar|
        Noise.create(description: bar["name"],
                     noise_type: "Bar",
                     lat: bar["latitude"],
                     lon: bar["longitude"],
                     decibel: 70,
                     reach: 200
                     )
    end
    page_num += 1
end

## Add Stationary Locations!
def get_json(file)
  if file.match(/\//)
    file_string = File.read("./lib/assets/points/#{file}.json")
    JSON.parse(file_string)
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
      lat: r["geometry"]["coordinates"][0],
      lon: r["geometry"]["coordinates"][1],
      decibel: decibel,
      reach: reach,
      seasonal: seasonal
    )
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
  "Fire Station" => { file: "znfv-apni", decibel: 125, reach: 45932, seasonal: false },
  "School" => { file: "pmap-kbvr", decibel: 70, reach: 104, seasonal: true },
  "College" => { file: "qawk-qmwr", decibel: 70, reach: 104, seasonal: true },
  "Trolley" => { file: "4qvq-uf9z", decibel: 65, reach: 60, seasonal: false },
  "Hospitals" => { file: "custom/seattle-er", decibel: 125, reach: 45932, seasonal: false }
}

gis_stationary = {
  "Police" => { file: "gis/police", decibel: 125, reach: 45932, seasonal: false },
  "Bus Stop" => { file: "gis/bus_stops", decibel: 74, reach: 164, seasonal: false },
  "Dump" => { file: "gis/solid_waste", decibel: 93, reach: 1509, seasonal: false },
  "Transit Center" => { file: "gis/transit_centers", decibel: 74, reach: 164, seasonal: false },
}

# Create Stationary Noises!
regular_stationary.each do |k, v|
  stationary_locations(k, v[:file], v[:decibel], v[:reach], v[:seasonal])
end

gis_stationary.each do |k, v|
  gis_stationary_locations(k, v[:file], v[:decibel], v[:reach], v[:seasonal])
end
