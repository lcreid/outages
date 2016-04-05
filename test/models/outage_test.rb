require 'test_helper'

class OutageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
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

  test "No end date" do
    o = outages(:error_no_end_time)
    assert_equal "2016-01-01 00:00:00", o.end_datetime_in_time_zone_s
  end
end
