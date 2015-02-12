class NoisesController < ApplicationController

  def index
    @noises = Noise.select('id, noise_type, lat, lon, decibel, reach')
    render json: @noises, status: 200
  end

  def score
    @latitude = params["latitude"].to_f
    @longitude = params["longitude"].to_f
    if !Noise.in_seattle?(@latitude, @longitude)
      render json: "No results", status: 400
    else
      results = Noise.get_score(@latitude, @longitude)
      @grade = results[:score]
      @nearby_noises = results[:noises]
    end
  end

  def coordinates
    @address = params[:address]
    @coordinates = [47.609998, -122.334362]
    
    render json: @coordinates, status: 200
  end
end
