## Clear Out Current Database
Noise.destroy_all
Perishable.destroy_all

## Add Stationary Locations
def stationary_locations(file, noise_type, decibel, seasonal)
  results = HTTParty.get("https://data.seattle.gov/resource/#{file}.json").parsed_response
  results.each do |r|
    Noise.create(
      description: r["common_name"],
      noise_type: noise_type,
      lat: r["latitude"],
      lon: r["longitude"],
      decibel: decibel,
      seasonal: seasonal
    )
    print "."
  end

  puts "\n#{noise_type} Imported"  
end

# Fire Stations
stationary_locations("znfv-apni", "Fire Station", 0, false)

# Public Schools
stationary_locations("pmap-kbvr", "School", 0, true)

# Higher Education
stationary_locations("qawk-qmwr", "College", 0, true)

# SLU Trolley Stops
stationary_locations("4qvq-uf9z", "Trolley", 70, false)