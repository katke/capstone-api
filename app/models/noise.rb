class Noise < ActiveRecord::Base

  def self.get_score(latitude, longitude)
    noises = nearby_noises(latitude, longitude)
    total = get_decibel_total(noises)

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
    lat_upper_limit = latitude + 0.004
    lat_lower_limit = latitude - 0.004
    lon_upper_limit = longitude + 0.004
    lon_lower_limit = longitude - 0.004
    Noise.where("lat BETWEEN ? AND ? AND lon BETWEEN ? AND ?", lat_lower_limit, lat_upper_limit, lon_lower_limit, lon_upper_limit)
  end

  def self.get_decibel_total(array_of_noises)
    array_of_noises.inject(0) { |sum, n| sum + n.decibel }
  end
end
