class OutagesController < ApplicationController
  CALENDAR_VIEWS = ['month', 'week', 'four-day', 'day']
  # Could I put the time one in a cookie?
  # For index, show, new, edit, the view looks to see if the
  # cookie has a time zone value. If it does, the field is set
  # to the time zone. If not, it calls the JavaScript code to
  # set the time zone.
  # For create and update, the time zone comes in the parameters.
  # The action sets the cookie.
  # So how do we send in the time zone in the parameters.
  # We have a hidden field in the form that gets filled in by
  # JavaScript every time the user selects a new time zone.
  # Or, JavaScript can set cookie values (document.cookie = ),
  # so we just adjust the cookie when the user makes a selection.
  # I hope the action gets the modified cookie.

  helper_method :cookies

  def index
    @outages = Outage.all
  end

  def month
    # TODO: order by start datetime and select only in the current calendar.
    @outages = Outage.all
    # TODO: Fix the group by to use the date.
    @outages_by_date = @outages.group_by(&:start_date)
    # puts @outages_by_date
    @date = Date.today
  end

  def week
  end

  def four_day
  end

  def day
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
    # puts "Outage: #{outage_params.inspect} @outage.time_zone #{@outage.time_zone}"
    cookies[:time_zone] = outage_params[:time_zone]

    if @outage.save
      redirect_to @outage
    else
      render 'new'
    end
  end

  def update
    @outage = Outage.find(params[:id])
    cookies[:time_zone] = outage_params[:time_zone]

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
    date.strip + 'T' + time.strip
  end
end
