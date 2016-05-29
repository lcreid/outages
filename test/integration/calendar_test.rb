require 'test_helper'

class CalendarTest < ActionDispatch::IntegrationTest
  test "Show day and move back and forth" do
    date = Date.new(2016, 3, 15)
    # Set the time zone cookie
    visit day_outages_path(date: date)
    assert_current_path(time_zone_path, only_path: true)
    click_on 'Submit'
    assert_current_path(day_outages_path(date: date))
    # Now we're ready to start
    click_on '<<'
    assert_current_path(day_outages_path(date: date.prev_day))
    click_on '>>'
    assert_current_path(day_outages_path(date: date))
  end
end
