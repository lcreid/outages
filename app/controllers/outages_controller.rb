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
    # Combine dates and times.
    params[:outage][:start_time] = combine(params[:outage][:start_date], params[:outage][:start_time])
    params[:outage][:end_time] = combine(params[:outage][:end_date], params[:outage][:end_time])
    @outage = Outage.new(outage_params)

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

  def combine(date, time)
    date.strip + "T" + time.strip
  end
end
