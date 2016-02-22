class Outage < ApplicationRecord
  def start_time_utc
    ActiveSupport::TimeZone[time_zone].parse(start_time)
  end

  def end_time_utc
    ActiveSupport::TimeZone[time_zone].parse(end_time)
  end
end
