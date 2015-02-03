class NoisesController < ApplicationController

  def index
    @noises = Noise.all
    render json: @noises, status: 200
  end

  def score
    @latitude = params["latitude"].to_f
    @longitude = params["longitude"].to_f
    render json: "foo!"
  end

end
