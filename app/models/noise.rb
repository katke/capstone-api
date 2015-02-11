class Noise < ActiveRecord::Base
  geocoded_by :description, :latitude  => :lat, :longitude => :lon

  def self.get_score(latitude, longitude)
    results = {}
    results[:noises] = nearby_noises(latitude, longitude)
    total = get_decibel_total(latitude, longitude, results[:noises])

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

    return results
  end

  def self.nearby_noises(latitude, longitude)
    Noise.near([latitude, longitude], 0.13)
  end

  def self.group_noises(array)
    groups = array.group(:noise_type, :description).count
    puts groups

    return array
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
