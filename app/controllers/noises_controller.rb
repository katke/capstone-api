class NoisesController < ApplicationController

  def index
    @noises = Noise.all
    render json: @noises, status: 200
  end

end
