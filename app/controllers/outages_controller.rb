class OutagesController < ApplicationController
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
  include OutagesHelper

  def index
    @outages = Outage.all
  end

  def show
    @outage = Outage.find(params[:id])
  end

  def new
    @outage = Outage.new
    user_time_zone
  end

  def edit
    @outage = Outage.find(params[:id])
    user_time_zone
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
    date.strip + 'T' + time.strip
  end

  def user_time_zone
    puts 'In user_time_zone'
    @user = User.new
    puts "Time Zone: #{params[:user][:time_zone]}"
    @user.time_zone = params[:user][:time_zone]
  end
end
