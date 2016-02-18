class OutagesController < ApplicationController
  def index
  end

  def show
    @outage = Outage.find(params[:id])
  end

  def new
  end

  def edit
  end

  def create
    # render plain: params[:outage].inspect
    @outage = Outage.new(outage_params)

    # TODO: Combine dates and times.
    # TODO: Use time zone

    @outage.save
    redirect_to @outage
  end

  def update
  end

  def destroy
  end

  private
  def outage_params
    params[:outage].permit(:title, :start_time, :end_time, :time_zone, :description)
  end
end
