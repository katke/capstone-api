class Noise < ActiveRecord::Base

  def self.get_score(latitude, longitude)
    "A"
  end

  def self.nearby_noises(latitude, longitude)
    lat_upper_limit = latitude + 0.004
    lat_lower_limit = latitude - 0.004
    lon_upper_limit = longitude + 0.004
    lon_lower_limit = longitude - 0.004
    Noise.where("lat BETWEEN ? AND ? AND lon BETWEEN ? AND ?", lat_lower_limit, lat_upper_limit, lon_lower_limit, lon_upper_limit)
  end
end
