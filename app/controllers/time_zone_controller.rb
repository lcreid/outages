class TimeZoneController < ApplicationController
  include TimeZoneHelper

  def edit
    # puts 'IN edit...'
  end

  def update
    # puts 'IN update...'
    # puts 'Params: ' + params.to_unsafe_hash.to_s
    cookies['time_zone'] = URI.decode(params
                                      .require(:time_zone)
                                      .permit(:time_zone)[:time_zone])
    puts 'TimeZoneController.update just set the cookie: ' + cookies['time_zone']
    puts 'Now the cookie is: ' + cookies['time_zone']
    if params[:redirect]
      # puts 'params[:redirect]: ' + params[:redirect]
      redirect_to params[:redirect]
    else
      redirect_back fallback_location: :root
    end
  end
end
