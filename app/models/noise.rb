class Noise < ActiveRecord::Base
  geocoded_by :description, :latitude  => :lat, :longitude => :lon

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
    Noise.near([latitude, longitude], 0.13)
  end

  def self.get_decibel_total(array_of_noises)
    array_of_noises.inject(0) { |sum, n| sum + n.decibel }
    #   Geocoder::Calculations.distance_between()
  end
end
