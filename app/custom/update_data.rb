class UpdateData

  def self.remove_existing_records
    noises = Noise.where(noise_type: "construction" OR noise_type: "demolition" OR noise_type: "noiseComplaints")
  end

  def self.test
    puts "Hooray it finally worked"
  end

end

# def get_json(file)
#   # demolition data
#   if file == "j6ng-5q2r"
#     HTTParty.get("https://data.seattle.gov/resource/#{file}.json?status=permit%20issued").parsed_response
#   # construction data
#   elsif file == "9yds-qdb3"
#     HTTParty.get("https://data.seattle.gov/resource/#{file}.json?status=permit%20issued&action_type=new").parsed_response
#   # 911 noise complaints
#   elsif file == "3k2p-39jp"
#     HTTParty.get("https://data.seattle.gov/resource/#{file}.json?event_clearance_description=noise%20disturbance&$limit=1000&$order=event_clearance_date%20DESC")
#   end
# end
#
# def perishable_locations(noise_type, file, decibel, reach, seasonal)
#   puts "\n[Starting #{noise_type}]"
#   results = get_json(file)
#
#   results.each do |r|
#     # Checks for existing expiration date
#     if r["expiration_date"]
#       # Check that permit is active
#       result = Date.today <=> r["expiration_date"].to_date
#       if result == -1
#         noise = Noise.create(
#           description: r["description"],
#           noise_type: noise_type,
#           lat: r["latitude"],
#           lon: r["longitude"],
#           decibel: decibel,
#           reach: reach,
#           seasonal: seasonal
#         )
#
#         Perishable.create(
#           noise_id: noise.id,
#           start: r["issue_date"],
#           end: r["expiration_date"]
#         )
#
#         print "."
#       end
#     end
#   end
#
#   puts "\n#{noise_type} Imported"

# end
