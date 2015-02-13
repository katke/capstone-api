class NoisesController < ApplicationController
  rescue_from Noise::InvalidAddress, with: :invalid_address_rescue

  def index
    @noises = Noise.select('id, noise_type, lat, lon, decibel, reach')
    render json: @noises, status: 200
  end

  def score
    @latitude = params["latitude"].to_f
    @longitude = params["longitude"].to_f
    if !Noise.in_seattle?(@latitude, @longitude)
      render json: "No Results", status: 400
    else
      results = Noise.get_score(@latitude, @longitude)
      @grade = results[:score]
      @nearby_noises = results[:noises]
    end
  end

  def coordinates
    @address = params[:address]
    @coordinates = Noise.get_coordinates(@address)

    render json: @coordinates, status: 200
  end


  private

  def invalid_address_rescue
    render json: "Invalid Address", status: 400
  end
end
