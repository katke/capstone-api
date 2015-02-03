class Noise < ActiveRecord::Base
  
  def self.get_score(latitude, longitude)
    "A"
  end

  def self.nearby_noises(latitude, longitude)
    Noise.where("lat = ? AND lon = ?", 47.902, -122.9)
  end
end
