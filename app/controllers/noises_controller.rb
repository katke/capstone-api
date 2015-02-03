class NoisesController < ApplicationController

  def index
    @noises = Noise.all
    render json: @noises, status: 200
  end

  def score
    @latitude = params["latitude"].to_f
    @longitude = params["longitude"].to_f
    if @latitude == 0 || @longitude == 0
      render json: "No results", status: 400
    else
      @grade = "A"
      render json: @grade
    end
  end

end
