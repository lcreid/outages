require "test_helper"

class OutagesControllerTest < ActionDispatch::IntegrationTest
  include TimeZoneHelper

  class <<self
    # I think this has to be a class method because it"s called before
    # the class has been instantiated. It took a while to figure that out.
    def assert_calendar(view,
                        number_of_events,
                        test_time = Time.local(2016, 2, 1))
      test "should get current #{view} view" do
        self.current_time_zone = "Samoa"
        Timecop.freeze(test_time) do
          get "/outages/#{view}"
          assert_response :success
          # puts response.body
          assert_select(".calendar-#{view}", 1) do |calendar|
            assert_select calendar, ".title", number_of_events
          end
        end
      end
    end
  end

  # OutagesController::CALENDAR_VIEWS.map.with_index do |view, i|
  assert_calendar("month", 3)
  assert_calendar("week", 1)
  assert_calendar("four-day", 1, Time.local(2016, 2, 12))
  assert_calendar("day", 4, Time.local(2016, 6, 15))
  # FIXME: schedule view should do something different
  assert_calendar("schedule", 4, Time.local(2016, 6, 15))

  test "rows in day view" do
    day_view_test(Time.local(2016, 6, 15), 48)
  end

  test "rows in day view on DST change long" do
    day_view_test(Time.local(2016, 11, 6), 50)
  end

  test "rows in day view on DST change short" do
    day_view_test(Time.local(2016, 3, 13), 46)
  end

  def day_view_test(date, result_count)
    self.current_time_zone = "America/Los_Angeles"
    get "/outages/day?date=#{date.strftime('%Y-%m-%d')}"
    assert_response :success
    assert_select ".day-by-half-hour li", result_count
  end
end
