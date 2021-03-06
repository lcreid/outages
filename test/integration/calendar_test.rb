require "test_helper"
require "capybara/poltergeist"

class CalendarTest < ActionDispatch::IntegrationTest
  include TimeZoneHelper

  def setup
    Capybara.javascript_driver = :poltergeist
  end

  def calendar_test(date, path, prev_date)
    # Set the time zone cookie
    visit path.call(date: date)
    assert_current_path(time_zone_path, only_path: true)
    click_on "Submit"
    assert_current_path(path.call(date: date))
    # Now we"re ready to start
    Time.use_zone(current_time_zone) do
      click_on "<<"
      assert_current_path(path.call(date: prev_date.call(date)))
      click_on ">>"
      assert_current_path(path.call(date: date))
    end
  end

  test "Show day and move back and forth" do
    calendar_test(Date.new(2016, 6, 15),
                  ->(date) { day_outages_path(date) },
                  ->(date) { date.prev_day })
  end

  test "Show week and move back and forth" do
    calendar_test(Date.new(2016, 3, 15),
                  ->(date) { week_outages_path(date) },
                  ->(date) { date.weeks_ago(1) })
  end

  test "Show month and move back and forth" do
    calendar_test(Date.new(2016, 3, 15),
                  ->(date) { month_outages_path(date) },
                  ->(date) { date.prev_month })
  end

  test "Show four-day and move backand forth" do
    calendar_test(Date.new(2016, 3, 15),
                  ->(date) { four_day_outages_path(date) },
                  ->(date) { date.days_ago(4) })
  end

  test "Show all the different calendar views" do
    date = Date.new(2016, 3, 15)
    # Set up time zone
    visit day_outages_path(date: date)
    click_on "Submit"
    # Ready to go
    assert_current_path day_outages_path(date: date)
    click_on "Week"
    assert_current_path week_outages_path(date: date)
    click_on "Four Day"
    assert_current_path four_day_outages_path(date: date)
    click_on "Month"
    assert_current_path month_outages_path(date: date)
    click_on "Day"
    assert_current_path day_outages_path(date: date)
  end
end
