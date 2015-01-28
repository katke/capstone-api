class NoisesController < ApplicationController

  def index
    @noises = Noise.all
    render json: "foo", status: 200
  end

end