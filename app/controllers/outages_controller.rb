class OutagesController < ApplicationController
  include TimeZoneHelper

  # See the end of this file for thoughts on time zone handling.

  # helper_method :cookies

  # before_action at the end of this file.

  # TODO: Figure out why I couldn"t use my method here.
  before_action :set_requested_date,
                only: [:month, :week, :four_day, :day, :schedule]

  def index
    @outages = Outage.all
  end

  def month
    calendar_action(@date
                    .beginning_of_month
                    .beginning_of_week,
                    @date
                    .end_of_month
                    .end_of_week
                    .next_day)
    @prev = @date.prev_month
    @next = @date.next_month
  end

  def week
    calendar_action(@date.beginning_of_week, (@date + 1.week).beginning_of_week)
    @prev = @date.weeks_ago(1)
    @next = @date.weeks_since(1)
  end

  def four_day
    calendar_action(@date, @date + 4.days)
    @prev = @date.days_ago(4)
    @next = @date.days_since(4)
  end

  def day
    calendar_action(@date, @date.next_day)
    @prev = @date.prev_day
    @next = @date.next_day
  end

  def schedule
    calendar_action(@date, @date.next_day)
  end

  def show
    # puts "In show time zone is: " + current_time_zone
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
      render "new"
    end
  end

  def update
    params_for_saving = parms_with_time_zone_for_saving
    @outage = Outage.find(params[:id])

    if @outage.update(params_for_saving)
      redirect_to @outage
    else
      render "edit"
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
    # TODO: Validate that date and time aren"t nil.
    date.strip + "T" + time.strip
  end

  def require_time_zone
    # puts "no cookie" unless current_time_zone
    # raise NO_TIME_ZONE_MSG unless current_time_zone
    # puts "request.path " + request.path
    # puts "REDIRECTING..."
    redirect_to time_zone_path(redirect: request.fullpath) unless current_time_zone
  end

  def parms_with_time_zone_for_saving
    raise "Internal error: no time zone set." unless current_time_zone
    params[:outage][:time_zone] = current_time_zone
    outage_params
  end

  # Some methods to support routing and testing of the calendar views.

  CALENDAR_VIEWS = ["month", "week", "four-day", "day", "schedule"]

  def self.calendar_views
    CALENDAR_VIEWS
  end

  def self.calendar_actions
    CALENDAR_VIEWS.map { |x| x.gsub(/[- ]/, "_").to_sym }
  end

  def set_requested_date
    @date = params[:date] ? Date.parse(params[:date]) : Date.today
  end

  def calendar_action(start_date, end_date)
    @start_date = start_date
    @end_date = end_date

    # puts "Start date: #{@start_date}, end date: #{@end_date}"

    # TODO: order by start datetime and select only in the current calendar.
    # TODO: By storing the dates and times in a variety of time zones,
    # this becomes a major performance issue. We have to select all and
    # use filtering once we get things into Ruby objects.
    # Fascinating: The fact that we don"t restrict the range of items we"re
    # looking at affects the algorithm for the calendar, because we can"t
    # or don"t want to enumerate massively long intervals.
    @outages = Outage.all.select do |x|
      # If I don't make the Dates into Times with beginning_of_day,
      # intersects? doesn't work.
      x.intersects?(@start_date.beginning_of_day, @end_date.beginning_of_day)
    end
    # puts "Outages: ", JSON.pretty_generate(@outages)
    @outages_by_date = @outages.reduce({}) do |a, e|
      a.merge(e.days) { |_k, o, n| o + n }
    end
    # puts "Outages by Date before trim: ", JSON.pretty_generate(@outages_by_date)
    @outages_by_date.delete_if do |k, _v|
      !(@start_date.beginning_of_day...@end_date.beginning_of_day).cover?(k)
    end
    # puts "Outages by Date after trim: ", JSON.pretty_generate(@outages_by_date)
  end

  before_action :require_time_zone,
                except: [:create, :update, :destroy]

  around_action :set_time_zone
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
bar, we won"t have any indication of the user"s time zone.

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
can"t just apply the "current offset from UTC" to the time
from the server.
=end
