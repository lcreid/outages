require 'test_helper'

class OutageTest < ActiveSupport::TestCase
  MISSING_MESSAGE = "can't be blank"
  DATE_FORMAT_MESSAGE = "must be yyyy[-mm[-dd]]"
  TIME_FORMAT_MESSAGE = "must be hh[:mm[:ss]]"
  TIME_MISSING_MESSAGES = [ MISSING_MESSAGE, TIME_FORMAT_MESSAGE ]
  DATE_MISSING_MESSAGES = [ MISSING_MESSAGE, DATE_FORMAT_MESSAGE ]

  test "happy new year samoa" do
    o = outages(:happy_new_year_samoa)
    assert_equal Time.utc(2015, 12, 31, 10, 0, 0), o.start_datetime_utc
    assert_equal Time.utc(2015, 12, 31, 10, 0, 1), o.end_datetime_utc
  end

  test "happy new year samoa from vancouver" do
    o = outages(:happy_new_year_samoa)
    tz_name = "Pacific Time (US & Canada)"
    tz = ActiveSupport::TimeZone.new(tz_name)
    assert_equal Time.utc(2015, 12, 31, 10, 0, 0), o.start_datetime_in_time_zone(tz)
    assert_equal Time.utc(2015, 12, 31, 10, 0, 1), o.end_datetime_in_time_zone(tz)
    assert_equal Time.utc(2015, 12, 31, 10, 0, 0), o.start_datetime_in_time_zone(tz_name)
    assert_equal Time.utc(2015, 12, 31, 10, 0, 1), o.end_datetime_in_time_zone(tz_name)
    assert_equal "2015-12-31 02:00:00", o.start_datetime_in_time_zone_s(tz_name)
    assert_equal "2015-12-31 02:00:01", o.end_datetime_in_time_zone_s(tz_name)
  end

  test "happy new year london" do
    o = outages(:happy_new_year_london)
    assert_equal Time.utc(2016, 1, 1, 0, 0, 0), o.start_datetime_utc
    assert_equal Time.utc(2016, 1, 1, 0, 0, 1), o.end_datetime_utc
  end

  test "No start date" do
    o = outages(:error_no_start_date)
    assert_equal "0000-01-01 00:00:00", o.start_datetime_in_time_zone_s
  end

  test "No end time" do
    o = outages(:error_no_end_time)
    assert_equal "2016-01-01 00:00:00", o.end_datetime_in_time_zone_s
  end

  test "Start date before end date" do
    o = Outage.new(title: "end date before start date",
      start_date: "2016-04-04",
      start_time: "00:00:01",
      end_date: "2016-04-04",
      end_time: "00:00:00",
      time_zone: "Samoa")
    assert o.invalid?, "#{o.title} shouldn't be valid."
    assert_equal ["must be after start time"], o.errors[:end_time]
  end

  test "Start date and time exist" do
    o = outages(:date_time_exists_tests)
    empty_string = ""
    save = nil

    save, o.start_date = o.start_date, save
    assert o.invalid?, "#{o.title} shouldn't be valid with nil start date"
    assert_equal DATE_MISSING_MESSAGES, o.errors[:start_date]
    save, o.start_date = o.start_date, save

    empty_string, o.start_date = o.start_date, empty_string
    assert o.invalid?, "#{o.title} shouldn't be valid with blank start date"
    assert_equal DATE_MISSING_MESSAGES, o.errors[:start_date]
    empty_string, o.start_date = o.start_date, empty_string

    save, o.start_time = o.start_time, save
    assert o.invalid?, "#{o.title} shouldn't be valid with nil start time"
    assert_equal TIME_MISSING_MESSAGES, o.errors[:start_time]
    save, o.start_time = o.start_time, save

    empty_string, o.start_time = o.start_time, empty_string
    assert o.invalid?, "#{o.title} shouldn't be valid with blank start time"
    assert_equal TIME_MISSING_MESSAGES, o.errors[:start_time]
    empty_string, o.start_time = o.start_time, empty_string
  end

  test "End date and time exist" do
    o = outages(:date_time_exists_tests)
    empty_string = ""
    save = nil

    save, o.end_date = o.end_date, save
    assert o.invalid?, "#{o.title} shouldn't be valid with nil end date"
    assert_equal DATE_MISSING_MESSAGES, o.errors[:end_date]
    save, o.end_date = o.end_date, save

    empty_string, o.end_date = o.end_date, empty_string
    assert o.invalid?, "#{o.title} shouldn't be valid with blank end date"
    assert_equal DATE_MISSING_MESSAGES, o.errors[:end_date]
    empty_string, o.end_date = o.end_date, empty_string

    save, o.end_time = o.end_time, save
    assert o.invalid?, "#{o.title} shouldn't be valid with nil end time"
    assert_equal TIME_MISSING_MESSAGES, o.errors[:end_time]
    save, o.end_time = o.end_time, save

    empty_string, o.end_time = o.end_time, empty_string
    assert o.invalid?, "#{o.title} shouldn't be valid with blank end time"
    assert_equal TIME_MISSING_MESSAGES, o.errors[:end_time]
    empty_string, o.end_time = o.end_time, empty_string
  end

  test "End date before start date" do
    o = outages(:date_time_exists_tests)
    o.end_datetime_in_time_zone = o.start_datetime_in_time_zone - 1.day
    refute o.valid?, "#{o} should be invalid."
    assert_equal ["must be after start date"], o.errors[:end_date]
  end

  test "Start datetime equals end datetime" do
    o = outages(:date_time_exists_tests)
    assert o.valid?, "#{o} should be valid. Found #{o.errors.messages}"
    assert o.errors[:end_date].empty?, "End date errors not empty."
    assert o.errors[:end_time].empty?, "End time errors not emtpy."
  end

  test "Dates equal, end time before start time" do
    o = outages(:date_time_exists_tests)
    o.end_datetime_in_time_zone = o.start_datetime_in_time_zone - 1.second
    refute o.valid?, "#{o} should be invalid."
    assert_equal ["must be after start time"], o.errors[:end_time]
  end

  test "Invalid date and time formats" do
    o = Outage.new({
      start_date: "2014-123-01",
      start_time: ":00:aa",
      end_date: "2014-12-32",
      end_time: "abd"
      })
    refute o.valid? "#{o} should be invalid."
    assert_equal [DATE_FORMAT_MESSAGE], o.errors[:start_date]
    assert_equal [TIME_FORMAT_MESSAGE], o.errors[:start_time]
    assert_equal [DATE_FORMAT_MESSAGE, "must be after start date"], o.errors[:end_date]
    assert_equal [TIME_FORMAT_MESSAGE], o.errors[:end_time]
    assert_equal ["can't be blank"], o.errors[:time_zone]
  end

  test "Missing time_zone" do
    o = Outage.new({
      start_date: "2014-12-01",
      start_time: "08:30",
      end_date: "2014-12-01",
      end_time: "09:00"
      })
    refute o.valid? "#{o} should be invalid."
    assert_equal ["can't be blank"], o.errors[:time_zone]
  end
end
