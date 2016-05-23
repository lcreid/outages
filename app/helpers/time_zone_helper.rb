module TimeZoneHelper
  def current_time_zone
    cookies['time_zone']
  end

  def current_time_zone=(tz)
    puts "Setting the time zone cookie: " + tz
    cookies['time_zone'] = tz
  end
end
