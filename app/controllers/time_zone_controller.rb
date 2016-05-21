class TimeZoneController < ApplicationController
  def edit
    # puts 'IN edit...'
  end

  def update
    # puts 'IN update...'
    # puts 'Params: ' + params.to_unsafe_hash.to_s
    cookies[:time_zone] = params
                          .require(:time_zone)
                          .permit(:time_zone)[:time_zone]
    if params[:redirect]
      # puts 'params[:redirect]: ' + params[:redirect]
      redirect_to params[:redirect]
    else
      redirect_back fallback_location: :root
    end
  end
end