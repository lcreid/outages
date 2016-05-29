require 'test_helper'

class OutagesControllerTest < ActionDispatch::IntegrationTest
  include TimeZoneHelper

  class <<self
    # I think this has to be a class method because it's called before
    # the class has been instantiated. It took a while to figure that out.
    def assert_calendar(view, number_of_events)
      test "should get current #{view} view" do
        self.current_time_zone = "Samoa"
        test_time = Time.local(2016, 2, 1)
        Timecop.freeze(test_time) do
          get "/outages/#{view}"
          assert_response :success
          assert_select "##{view}" do |calendar|
            assert_select calendar, '.title', number_of_events
          end
        end
      end
    end
  end

  # OutagesController::CALENDAR_VIEWS.map.with_index do |view, i|
  assert_calendar('month', 3)
  assert_calendar('week', 3)
  assert_calendar('four-day', 3)
  assert_calendar('day', 3)
  assert_calendar('schedule', 3)
end
