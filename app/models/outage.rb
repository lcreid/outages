class Outage < ApplicationRecord
  def start_datetime_utc
    parse(start_datetime_s).utc
  end

  def end_datetime_utc
    parse(end_datetime_s).utc
  end

  def start_datetime_tz(tz)
    datetime_tz(tz, start_datetime_utc)
  end

  def end_datetime_tz(tz)
    datetime_tz(tz, end_datetime_utc)
  end

  private
  def parse(s)
    ActiveSupport::TimeZone[time_zone].parse(s)
  end

  def start_datetime_s
    datetime_s(start_date, start_time)
  end

  def end_datetime_s
    datetime_s(end_date, end_time)
  end

  def datetime_s(date, time)
    date + "T" + time
  end

  def to_tz(tz)
    return ActiveSupport::TimeZone[tz] if tz.class == String
    tz
  end

  def datetime_tz(tz, datetime)
    to_tz(tz).utc_to_local(datetime)
  end
end
