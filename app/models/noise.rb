class Noise < ActiveRecord::Base
  geocoded_by :description, :latitude  => :lat, :longitude => :lon

  class InvalidAddress < StandardError
  end

  def self.get_score(latitude, longitude)
    results = {}
    nearby_noises_array = nearby_noises(latitude, longitude)
    total = get_decibel_total(latitude, longitude, nearby_noises_array)

    if total >= 600
      results[:score] = "F"
    elsif total >= 450
      results[:score] = "E"
    elsif total >= 325
      results[:score] = "D"
    elsif total >= 200
      results[:score] = "C"
    elsif total >= 60
      results[:score] = "B"
    else
      results[:score] = "A"
    end

    results[:noises] = group_noises(nearby_noises_array)
    return results
  end

  def self.nearby_noises(latitude, longitude)
    Noise.near([latitude, longitude], 0.06)
  end

  def self.group_noises(array)
    if array.any?
      activerecordify = Noise.where(id: array.map(&:id))
      groups = activerecordify.group(:noise_type).count

      groups.map do |k, v|
        hash = { noise_type: get_descriptive_name(k, v), icon: get_icon(k), details: nil }
        if k == "construction" || k == "demolition" || k == "noiseComplaints"
          detailed_noises = activerecordify.where(noise_type: "#{k}");
          long_descriptions = detailed_noises.map do |i|
            format_description(i.description)
          end

          hash[:details] = long_descriptions
        elsif k == "freeway"
          freeway_count = activerecordify.where(noise_type: "freeway").group(:description).count.keys.length
          hash[:noise_type] = get_descriptive_name(k, freeway_count)
        end

        hash
      end
    else
      [{ noise_type: "No significant noises within range!", icon: "heart", details: nil }]
    end
  end

  def self.noise_data_hash(noise_type, data_requested)
    hash = {
      "fireStation" =>       { name: "Fire Station", icon: "fire" },
      "school" =>            { name: "School", icon: "book" },
      "college" =>           { name: "College", icon: "pencil" },
      "transit" =>           { name: "Transit Stop", icon: "road" },
      "hospital" =>          { name: "Hospital", icon: "plus-sign" },
      "bar" =>               { name: "Bar", icon: "glass" },
      "heliportOrAirport" => { name: "Heliport/Airport", icon: "plane" },
      "stadium" =>           { name: "Stadium", icon: "volume-up" },
      "policeStation" =>     { name: "Police Station", icon: "bullhorn" },
      "dump" =>              { name: "Dump", icon: "trash" },
      "construction" =>      { name: "Construction Site", icon: "wrench" },
      "demolition" =>        { name: "Demolition Site", icon: "warning-sign" },
      "noiseComplaints" =>   { name: "Noise Complaint", icon: "phone-alt" },
      "freeway" =>           { name: "Freeway", icon: "road" }
    }
    hash[noise_type][data_requested]
  end

  def self.get_descriptive_name(type, count)
    name = noise_data_hash(type, :name)
    "#{count} #{name.pluralize(count)}"
  end

  def self.format_description(string)
    string.capitalize
  end

  def self.get_icon(type)
    noise_data_hash(type, :icon)
  end

  def self.get_decibel_total(origin_lat, origin_lon, array_of_noises)
    noise_decibels = array_of_noises.map do |noise|
      distance = Geocoder::Calculations.distance_between([origin_lat, origin_lon], [noise.lat, noise.lon])
      # Inverse Square Law
      noise.decibel - ((distance/2) * 6)
    end
    noise_decibels.sum
  end

  def self.in_seattle?(latitude, longitude)
    if (latitude > 47.48172 && latitude < 47.734145) && (longitude < -122.224433 && longitude > -122.459696)
      true
    else
      false
    end
  rescue NoMethodError
    false
  end

  # cron task method to add new construction/demolition/noise complaint data, delete old data daily
  def self.refresh_data
    UpdateData.remove_existing_records
    UpdateData.repull_data
    puts "Construction, demolition, and noise complaints have been updated!"
  end

  def self.get_coordinates(address)
    clean_address = address.gsub(/ /, "+")
    url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{clean_address},Seattle,WA&key=#{ENV['GOOGLE_API_KEY']}"
    response = HTTParty.get(url).parsed_response["results"]

    first_location = response[0]["geometry"]["location"]

    if response.empty? || bad_result(response) || !in_seattle?(first_location["lat"], first_location["lng"])
      raise InvalidAddress
    else
      first_location
    end
  end

  def self.bad_result(response)
    if response[0]["geometry"]["location_type"] == "APPROXIMATE" && response[0]["types"] == [ "locality", "political" ]
      true
    else
      false
    end
  end
end
