class Outage < ApplicationRecord
  def start_time_utc
    parse(start_time)
  end

  def end_time_utc
    parse(end_time)
  end

  private
  def parse(s)
    ActiveSupport::TimeZone[time_zone].parse(s)
  end
end
