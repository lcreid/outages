class Outage < ApplicationRecord
  DATE_FORMAT = "%Y-%m-%d"
  TIME_FORMAT = "%H:%M:%S"
  DATETIME_FORMAT = DATE_FORMAT + " " + TIME_FORMAT
  MISSING_DATE = "0000-01-01"
  MISSING_TIME = "00:00:00"

  validates :start_date, :start_time, :end_date, :end_time, :time_zone, presence: true
  validate :date_and_time_formats
  validate :start_datetime_before_end_datetime

  def start_datetime_utc
    parse(start_datetime_s).utc
  end

  def end_datetime_utc
    parse(end_datetime_s).utc
  end

  def start_datetime_in_time_zone(tz = time_zone)
    datetime_in_time_zone(tz, start_datetime_utc)
  end

  def end_datetime_in_time_zone(tz = time_zone)
    datetime_in_time_zone(tz, end_datetime_utc)
  end

  def end_datetime_in_time_zone=(datetime)
    self.end_date = datetime.strftime(DATE_FORMAT)
    self.end_time = datetime.strftime(TIME_FORMAT)
    datetime
  end

  def start_datetime_in_time_zone_s(tz = time_zone)
    # puts "Start time zone: #{tz}"
    # puts datetime_in_time_zone(tz, start_datetime_utc)
    datetime_in_time_zone(tz, start_datetime_utc).strftime(DATETIME_FORMAT)
  end

  def end_datetime_in_time_zone_s(tz = time_zone)
    # puts "End time zone: #{tz}"
    # puts datetime_in_time_zone(tz, end_datetime_utc)
    datetime_in_time_zone(tz, end_datetime_utc).strftime(DATETIME_FORMAT)
  end

  def intersects?(start_time, end_time)
    # puts 'self.start: ' + start_datetime_in_time_zone.to_s
    # puts 'self.end: ' + end_datetime_in_time_zone.to_s
    # puts 'start: ' + start_time.to_s
    # puts 'end: ' + end_time.to_s
    !does_not_intersect?(start_time, end_time)
  end

  # Some background on this code is in order:
  # I figured this out on a project many years ago. I was going crazy trying
  # to write SQL queries that would bring back overlapping time periods.
  # I had already learned that the best thing to do was treat all intervals
  # as open, closed intervals, meaning the start time is in the interval,
  # while the end time is not. (Note: Don't necessarily do your user interface
  # this way).
  # Anyway, the breakthrough came as I was trying to draw all the combinations.
  # I realized that the ones that did _not_ overlap, are simply the ones that
  # where one ends before the other starts:
  # |-----|
  #    A
  #         |---|
  #           B
  #             |-----|
  #                C
  # A and B don't overlap because A ends before B starts. B and C don't
  # overlap because the end point of B isn't in the interval, so it too
  # ends before C starts.
  # That leads to the "does not intersect" below, and intersect is just
  # the inverse. (Bonus marks: Apply de Morgan's law to implement the
  # "intersect" method.)
  def does_not_intersect?(start_time, end_time)
    begin
      end_time <= start_datetime_in_time_zone ||
        end_datetime_in_time_zone <= start_time
    rescue
      true
    end
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
    (date || MISSING_DATE) + ' ' + (time || MISSING_TIME)
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
      errors.add(:end_date, "must be after start date")
    elsif (start_date == end_date) && (end_time <= start_time)
      errors.add(:end_time, "must be after start time")
    end
  end

  def date_and_time_formats
    date_format_message = "must be yyyy[-mm[-dd]]"
    time_format_message = "must be hh[:mm[:ss]]"

    begin
      Date.parse(start_date)
    rescue
      errors.add(:start_date, date_format_message)
    end
    begin
      Date.parse(end_date)
    rescue
      errors.add(:end_date, date_format_message)
    end
    begin
      DateTime.parse(start_time)
    rescue
      errors.add(:start_time, time_format_message)
    end
    begin
      DateTime.parse(end_time)
    rescue
      errors.add(:end_time, time_format_message)
    end
  end
end
