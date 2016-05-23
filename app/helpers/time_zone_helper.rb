module TimeZoneHelper
  def current_time_zone
    cookies['time_zone']
  end

  def current_time_zone=(tz)
    cookies['time_zone'] = tz
  end
end
