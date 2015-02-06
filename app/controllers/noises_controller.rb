class NoisesController < ApplicationController

  def index
    @noises = Noise.select('id, noise_type, lat, lon')
    render json: @noises, status: 200
  end

  def score
    @latitude = params["latitude"].to_f
    @longitude = params["longitude"].to_f
    if @latitude == 0 || @longitude == 0 || !Noise.in_seattle?(@latitude, @longitude)
      render json: "No results", status: 400
    else
      results = Noise.get_score(@latitude, @longitude) 
      @grade = results[:score]
      @nearby_noises = results[:noises]
    end
  end

end
