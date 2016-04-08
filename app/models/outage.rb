class Outage < ApplicationRecord
  DATE_FORMAT = "%Y-%m-%d"
  TIME_FORMAT = "%H:%M:%S"
  DATETIME_FORMAT = DATE_FORMAT + " " + TIME_FORMAT
  MISSING_DATE = "0000-01-01"
  MISSING_TIME = "00:00:00"

  validates :start_date, :start_time, :end_date, :end_time, presence: true
  validate :start_datetime_before_end_datetime

  def start_datetime_utc
    parse(start_datetime_s).utc
  end

  def end_datetime_utc
    parse(end_datetime_s).utc
  end

  def start_datetime_in_time_zone(tz = self.time_zone)
    datetime_in_time_zone(tz, start_datetime_utc)
  end

  def end_datetime_in_time_zone(tz)
    datetime_in_time_zone(tz, end_datetime_utc)
  end

  def end_datetime_in_time_zone=(datetime)
    self.end_date = datetime.strftime(DATE_FORMAT)
    self.end_time = datetime.strftime(TIME_FORMAT)
    datetime
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
    (date || MISSING_DATE) + " " + (time || MISSING_TIME)
  end

  # def to_tz(tz)
  #   return ActiveSupport::TimeZone[tz] if tz.class == String
  #   tz
  # end

  def datetime_in_time_zone(tz, datetime)
    datetime.in_time_zone(tz)
  end

  def start_datetime_before_end_datetime
    return if start_date.blank? || end_date.blank? ||
      start_time.blank? || end_time.blank?

    if end_date < start_date
      errors.add(:end_date, "Start date must be before end date.")
    elsif (start_date == end_date) && (end_time <= start_time)
      errors.add(:end_time, "Start time must be before end time.")
    end
  end
end
