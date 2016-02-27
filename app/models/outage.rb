class Outage < ApplicationRecord
  def start_datetime_utc
    parse(start_datetime_s).utc
  end

  def end_datetime_utc
    parse(end_datetime_s).utc
  end

  def start_datetime_tz(tz)
    # puts "UTC: " + start_datetime_utc.to_s
    # puts tz.name

    to_tz(tz).utc_to_local(start_datetime_utc)
  end

  def end_datetime_tz(tz)
    # puts "UTC: " + end_datetime_utc.to_s
    # puts tz.name

    to_tz(tz).utc_to_local(end_datetime_utc)
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

  def to_tz(tz)
    return ActiveSupport::TimeZone[tz] if tz.class == String
    tz
  end

  def datetime_tz(tz)
  end
end
