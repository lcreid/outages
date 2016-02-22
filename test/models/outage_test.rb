require 'test_helper'

class OutageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "happy new year samoa" do
    o = outages(:happy_new_year_samoa)
    assert_equal Time.utc(2015, 12, 31, 10, 0, 0), o.start_time_utc
    assert_equal Time.utc(2015, 12, 31, 10, 0, 1), o.end_time_utc
  end

  test "happy new year london" do
    o = outages(:happy_new_year_london)
    assert_equal Time.utc(2016, 1, 1, 0, 0, 0), o.start_time_utc
    assert_equal Time.utc(2016, 1, 1, 0, 0, 1), o.end_time_utc
  end
end
