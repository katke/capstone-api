## Clear Out Current Database!
puts "Clearing Database..."
Noise.destroy_all
Perishable.destroy_all

# Hash of Noises to Create!
noises_to_create = {
  "fireStation" =>       { file_type: "regular_stationary", file: "znfv-apni", decibel: 125, reach: 4593, seasonal: false, display_reach: 12 },
  "school" =>            { file_type: "regular_stationary", file: "pmap-kbvr", decibel: 70, reach: 10, seasonal: true, display_reach: 10 },
  "college" =>           { file_type: "regular_stationary", file: "qawk-qmwr", decibel: 74, reach: 16, seasonal: true, display_reach: 15 },
  "trolley" =>           { file_type: "regular_stationary", file: "4qvq-uf9z", decibel: 65, reach: 6, seasonal: false, display_reach: 2 },
  "hospital" =>          { file_type: "regular_stationary", file: "points/custom/seattle-er", decibel: 125, reach: 4593, seasonal: false, display_reach: 12 },
  "bar" =>               { file_type: "regular_stationary", file: "points/custom/bar_geolocation", decibel: 70, reach: 10, seasonal: false, display_reach: 2 },
  "heliportOrAirport" => { file_type: "regular_stationary", file: "points/custom/heliports", decibel: 100, reach: 3117, seasonal: false, display_reach: 8 },
  "stadium" =>           { file_type: "regular_stationary", file: "points/custom/stadiums", decibel: 100, reach: 263, seasonal: true, display_reach: 11 },
  "policeStation" =>     { file_type: "gis_stationary", file: "points/gis/police", decibel: 125, reach: 4593, seasonal: false, display_reach: 12 },
  "busStop" =>           { file_type: "gis_stationary", file: "points/gis/bus_stops", decibel: 74, reach: 16, seasonal: false, display_reach: 2 },
  "dump" =>              { file_type: "gis_stationary", file: "points/gis/solid_waste", decibel: 93, reach: 151, seasonal: false, display_reach: 6 },
  "transitCenter" =>     { file_type: "gis_stationary", file: "points/gis/transit_centers", decibel: 74, reach: 16, seasonal: false, display_reach: 2 },
  "construction" =>      { file_type: "stationary_perishable", file: "9yds-qdb3", decibel: 93, reach: 151, seasonal: false, display_reach: 6 },
  "demolition" =>        { file_type: "stationary_perishable", file: "j6ng-5q2r", decibel: 100, reach: 263, seasonal: false, display_reach: 9 },
  "noiseComplaints" =>   { file_type: "stationary_noise_complaints", file: "3k2p-39jp", decibel: 65, reach: 60, seasonal: false, display_reach: 2 },
  "freeway" =>           { file_type: "gis_roads", file: "lines/freeway", decibel: 80, reach: 30, description: "StateRoute", seasonal: false, display_reach: 0 },
  # "railroad" =>        { file_type: "gis_roads", file: "lines/railroads", decibel: 80, reach: 30, description: "Name", seasonal: false, display_reach: 0} ## Data seems inacurrate?
}

# Create Noises!
SeedData.import_data(noises_to_create)

# Everything's Done!
puts "Seeding Complete! #{Noise.count} Noises in Database! :)"
