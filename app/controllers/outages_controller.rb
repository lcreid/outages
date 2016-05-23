class OutagesController < ApplicationController
  include TimeZoneHelper

  # See the end of this file for thoughts on time zone handling.

  # helper_method :cookies

  # before_action at the end of this file.

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
    # puts 'In show time zone is: ' + current_time_zone
    @outage = Outage.find(params[:id])
  end

  def new
    @outage = Outage.new
  end

  def edit
    @outage = Outage.find(params[:id])
  end

  def create
    params_for_saving = parms_with_time_zone_for_saving
    @outage = Outage.new(params_for_saving)
    # puts "Outage: #{outage_params.inspect} @outage.time_zone #{@outage.time_zone}"

    if @outage.save
      redirect_to @outage
    else
      render 'new'
    end
  end

  def update
    params_for_saving = parms_with_time_zone_for_saving
    @outage = Outage.find(params[:id])

    if @outage.update(params_for_saving)
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
    params.require(:outage).permit(
      :title,
      :start_date,
      :start_time,
      :end_date,
      :end_time,
      :time_zone,
      :description)
  end

  def combine(date, time)
    # TODO: Validate that date and time aren't nil.
    date.strip + 'T' + time.strip
  end

  def require_time_zone
    # puts 'no cookie' unless current_time_zone
    # raise NO_TIME_ZONE_MSG unless current_time_zone
    # puts 'request.path ' + request.path
    # puts 'REDIRECTING...'
    redirect_to time_zone_path(redirect: request.path) unless current_time_zone
  end

  def parms_with_time_zone_for_saving
    raise "Internal error: no time zone set." unless current_time_zone
    params[:outage][:time_zone] = current_time_zone
    outage_params
  end

  # Some methods to support routing and testing of the calendar views.

  CALENDAR_VIEWS = ['month', 'week', 'four-day', 'day']

  def self.calendar_views
    CALENDAR_VIEWS
  end

  def self.calendar_actions
    CALENDAR_VIEWS.map { |x| x.gsub(/[- ]/, "_").to_sym }
  end

  before_action :require_time_zone,
                except: [:create, :update, :destroy]
end

=begin
At first I thought:
Could I put the time zone in a cookie?
For index, show, new, edit, the view looks to see if the
cookie has a time zone value. If it does, the field is set
to the time zone. If not, it calls the JavaScript code to
set the time zone.
For create and update, the time zone comes in the parameters.
The action sets the cookie.
So how do we send in the time zone in the parameters.
We have a hidden field in the form that gets filled in by
JavaScript every time the user selects a new time zone.
Or, JavaScript can set cookie values (document.cookie = ),
so we just adjust the cookie when the user makes a selection.
I hope the action gets the modified cookie.

Then I realized:
So the cookie thing falls apart on the first request. If the
user requests a page by, for example, typing into the address
bar, we won't have any indication of the user's time zone.

And then:
Whoa -- Should I do the time zone in the browser?
That would mean the server would always return UTC, and the
browser would do the change, which might also mean that we
could change the time zone in the browser only (but with
potential confusion because I might have selected a day based
on one time zone. Switching the time zone in the browser without
a new query might have the wrong records.)

Also, I wonder if the browser can really be trusted to do time
zones. We could be looking at something in the past or the future,
where DST is different from current, and therefore the browser
can't just apply the "current offset from UTC" to the time
from the server.
=end
