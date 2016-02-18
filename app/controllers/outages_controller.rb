class OutagesController < ApplicationController
  def create
    render plain: params[:outage].inspect
  end

  def new
  end
end
