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
          assert_select "##{view}" do |calendar|
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
end
