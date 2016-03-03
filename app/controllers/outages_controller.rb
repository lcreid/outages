class OutagesController < ApplicationController
  def index
    @outages = Outage.all
  end

  def show
    @outage = Outage.find(params[:id])
  end

  def new
    @outage = Outage.new
  end

  def edit
    @outage = Outage.find(params[:id])
  end

  def create
    @outage = Outage.new(outage_params)

    if @outage.save
      redirect_to @outage
    else
      render 'new'
    end
  end

  def update
    @outage = Outage.find(params[:id])

    if @outage.update(outage_params)
      redirect_to @outage
    else
      render 'edit'
    end
  end

  def destroy
    outage = Outage.find(params[:id])
    outage.destroy
    redirect_to outages_path
  end

  private
  def outage_params
    params.require(:outage).permit(:title, :start_date, :start_time, :end_date, :end_time, :time_zone, :description)
  end

  def combine(date, time)
    # TODO: Validate that date and time aren't nil.
    date.strip + "T" + time.strip
  end
end
