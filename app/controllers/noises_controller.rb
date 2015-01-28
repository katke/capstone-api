class NoisesController < ApplicationController

  def index
    render json: "foo", status: 200
  end

end