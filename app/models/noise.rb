class Noise < ActiveRecord::Base
  geocoded_by :description, :latitude  => :lat, :longitude => :lon

  def self.get_score(latitude, longitude)
    results = {}
    nearby_noises_array = nearby_noises(latitude, longitude)
    total = get_decibel_total(latitude, longitude, nearby_noises_array)

    if total >= 160
      results[:score] = "F"
    elsif total >= 90
      results[:score] = "E"
    elsif total >= 80
      results[:score] = "D"
    elsif total >= 70
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
    Noise.near([latitude, longitude], 0.13)
  end

  def self.group_noises(array)
    activerecordify = Noise.where(id: array.map(&:id))
    groups = activerecordify.group(:noise_type).count

    groups.map do |k, v|
      hash = { noise_type: k, count: v, details: nil }
      # hash = { noise_type: get_descriptive_name(k, v), details: nil, icon: get_icon(k) }

      if k == "construction" || k == "demolition" || k == "noiseComplaints"
        detailed_noises = activerecordify.where("noise_type = 'construction' OR noise_type = 'demolition' OR noise_type = 'noiseComplaints'")
        long_descriptions = detailed_noises.map(&:description)
        # long_descriptions = detailed_noises.map do |i|
        #   format_description(i.description)
        # end

        hash[:details] = long_descriptions
      elsif k == "freeway"
        freeway_count = activerecordify.where(noise_type: "freeway").group(:description).count.keys.length
        hash[:count] = freeway_count
        # hash[:noise_type] = get_descriptive_name(k, freeway_count)
      end

      hash
    end
  end

  def self.get_descriptive_name(type, count)
    names_hash = {
      "fireStation" => "Fire Station",
      "school" => "School",
      "college" => "College",
      "transit" => "Transit Stop",
      "hospital" => "Hospital",
      "bar" => "Bar",
      "heliportOrAirport" => "Heliport/Airport",
      "stadium" => "Stadium",
      "policeStation" => "Police Station",
      "dump" => "Dump",
      "construction" => "Construction",
      "demolition" => "Demolition",
      "noiseComplaints" => "Noise Complaint",
      "freeway" => "Freeway"
    }

    "#{count} #{names_hash[type].pluralize(count)}"
  end

  def self.format_description(string)
    string.capitalize
  end

  def self.get_icon(type)
    icons_hash = {
      "fireStation" => "fire",
      "school" => "book",
      "college" => "pencil",
      "transit" => "road",
      "hospital" => "plus-sign",
      "bar" => "glass",
      "heliportOrAirport" => "plane",
      "stadium" => "volume-up",
      "policeStation" => "bullhorn",
      "dump" => "trash",
      "construction" => "wrench",
      "demolition" => "wrench",
      "noiseComplaints" => "phone-alt",
      "freeway" => "road"
    }

    icons_hash[type]
  end

  def self.get_decibel_total(origin_lat, origin_lon, array_of_noises)
    noise_decibels = array_of_noises.map do |noise|
      distance = Geocoder::Calculations.distance_between([origin_lat, origin_lon], [noise.lat, noise.lon])
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
end
