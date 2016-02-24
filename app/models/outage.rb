class Outage < ApplicationRecord
  def start_datetime_utc
    parse(start_datetime_s)
  end

  def end_datetime_utc
    parse(end_datetime_s)
  end

  private
  def parse(s)
    ActiveSupport::TimeZone[time_zone].parse(s)
  end

  def start_datetime_s
    start_date + "T" + start_time
  end

  def end_datetime_s
    end_date + "T" + end_time
  end
end
