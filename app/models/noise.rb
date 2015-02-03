class Noise < ActiveRecord::Base
  geocoded_by :description, :latitude  => :lat, :longitude => :lon

  def self.get_score(latitude, longitude)
    noises = nearby_noises(latitude, longitude)
    total = get_decibel_total(latitude, longitude, noises)

    if total >= 160
      "F"
    elsif total >= 90
      "E"
    elsif total >= 80
      "D"
    elsif total >= 70
      "C"
    elsif total >= 60
      "B"
    else
      "A"
    end
  end

  def self.nearby_noises(latitude, longitude)
    Noise.near([latitude, longitude], 0.13)
  end

  def self.get_decibel_total(origin_lat, origin_lon, array_of_noises)
    noise_decibels = array_of_noises.map do |noise|
      distance = Geocoder::Calculations.distance_between([origin_lat, origin_lon], [noise.lat, noise.lon])
      noise.decibel - ((distance/2) * 6)
    end
    noise_decibels.sum
  end
end
