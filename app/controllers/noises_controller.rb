class NoisesController < ApplicationController

  def index
    @noises = Noise.all
    render json: @noises, status: 200
  end

  def score
    @latitude = params["latitude"]
    @longitude = params["longitude"]
    render json: "foo!"
  end

end
