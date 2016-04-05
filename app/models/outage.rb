class Outage < ApplicationRecord
  DATETIME_FORMAT = "%Y-%m-%d %H:%M:%S"
  MISSING_DATE = "0000-01-01"
  MISSING_TIME = "00:00:00"

  def start_datetime_utc
    parse(start_datetime_s).utc
  end

  def end_datetime_utc
    parse(end_datetime_s).utc
  end

  def start_datetime_in_time_zone(tz)
    datetime_in_time_zone(tz, start_datetime_utc)
  end

  def end_datetime_in_time_zone(tz)
    datetime_in_time_zone(tz, end_datetime_utc)
  end

  def start_datetime_in_time_zone_s(tz = self.time_zone)
    # puts "Start time zone: #{tz}"
    # puts datetime_in_time_zone(tz, start_datetime_utc)
    datetime_in_time_zone(tz, start_datetime_utc).strftime(DATETIME_FORMAT)
  end

  def end_datetime_in_time_zone_s(tz = self.time_zone)
    # puts "End time zone: #{tz}"
    # puts datetime_in_time_zone(tz, end_datetime_utc)
    datetime_in_time_zone(tz, end_datetime_utc).strftime(DATETIME_FORMAT)
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
    (date || MISSING_DATE) + "T" + (time || MISSING_TIME)
  end

  # def to_tz(tz)
  #   return ActiveSupport::TimeZone[tz] if tz.class == String
  #   tz
  # end

  def datetime_in_time_zone(tz, datetime)
    datetime.in_time_zone(tz)
  end
end
