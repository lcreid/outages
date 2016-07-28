require "test_helper"

class OutagesControllerTest < ActionDispatch::IntegrationTest
  include TimeZoneHelper

  NUMBER_OF_OUTAGE_FIXTURES = 16

  test "should get index" do
    self.current_time_zone = "Samoa"
    get "/outages"
    assert_response :success
    assert_not_nil assigns(:outages)
  end

  test "should show ID 1" do
    self.current_time_zone = "Samoa"
    get "/outages/1"
    assert_response :success
    assert_not_nil assigns(:outage)
  end

  test "should get new outage" do
    self.current_time_zone = "Samoa"
    get "/outages/new"
    assert_response :success
    assert_not_nil assigns(:outage)
  end

  test "should edit outage 1" do
    self.current_time_zone = "Samoa"
    get "/outages/1/edit"
    assert_response :success
    assert_not_nil(o = assigns(:outage))
    assert_equal 1, o.id
  end

  test "should create outage" do
    self.current_time_zone = "Samoa"
    assert_difference "Outage.count" do
      post "/outages", params: {
        outage: {
          title: "Functional 1",
          start_date: "2016-03-02",
          start_time: "18:37",
          end_date: "2016-03-02",
          end_time: "20:00"
        }
      }
    end
    assert_redirected_to outage_path(assigns(:outage))
  end

  test "should update outage 1" do
    self.current_time_zone = "Samoa"
    new_title = "Happy New New Year Samoa"
    assert_no_difference "Outage.count" do
      put "/outages/1", params: {
        outage: {
          title: new_title,
          start_date: "2016-01-01",
          start_time: "00:00:00",
          end_date: "2016-01-01",
          end_time: "00:00:01"
        }
      }
    end
    assert_not_nil(o = assigns(:outage))
    assert_equal new_title, o.title
    assert_redirected_to outage_path(o)
  end

  test "should destroy outage 3" do
    assert_difference "Outage.count", -1 do
      delete "/outages/3"
    end
    assert_redirected_to outages_path
  end

  test "should get index with time_zone from cookie" do
    self.current_time_zone = "Pacific/Pago_Pago"
    get "/outages"
    assert_response :success
    assert_not_nil assigns(:outages)
    # don"t have this anymore assert_select "#time_zone_setter option[selected]", tz
    assert_select "tbody" do |table|
      assert_select table, "tr", NUMBER_OF_OUTAGE_FIXTURES do |rows|
        assert_select rows[0], "td" do |elements|
          assert_equal "2015-12-30 23:00:00", elements[1].text
          assert_equal "2015-12-30 23:00:01", elements[2].text
        end
        assert_select rows[1], "td" do |elements|
          assert_equal "2015-12-31 13:00:00", elements[1].text
          assert_equal "2015-12-31 13:00:01", elements[2].text
        end
        assert_select rows[2], "td" do |elements|
          assert_equal "2015-12-31 13:00:00", elements[1].text
          assert_equal "2015-12-31 13:00:01", elements[2].text
        end
      end
    end
  end

  # The next two are no longer valid, since we don"t set cookie
  # in those actions.
  # test "post/create should set cookie from time zone setter" do
  #   post "/outages?time_zone=Samoa", params: {
  #     outage: {
  #       title: "set time zone",
  #       start_date: "2016-01-01",
  #       start_time: "00:00:00",
  #       end_date: "2016-01-01",
  #       end_time: "00:00:01",
  #       time_zone: tz = "Pacific/Pago_Pago"
  #     }
  #   }
  #   assert_redirected_to outage_path(assigns(:outage))
  #   # OMG: The cookies key has to be a string in the test case.
  #   assert_equal tz, self.current_time_zone
  # end

  # test "put/update should set cookie from time zone setter" do
  #   put "/outages/1", params: {
  #     outage: {
  #       title: "set time zone",
  #       start_date: "2016-01-01",
  #       start_time: "00:00:00",
  #       end_date: "2016-01-01",
  #       end_time: "00:00:01",
  #       time_zone: tz = "Pacific/Pago_Pago"
  #     }
  #   }
  #   assert_redirected_to outage_path(assigns(:outage))
  #   # OMG: The cookies key has to be a string in the test case.
  #   assert_equal tz, self.current_time_zone
  # end

  test "create should raise error when no time zone" do
    assert_raises RuntimeError do
      post "/outages", params: {
        outage: {
          title: "no time zone create",
          start_date: "2016-01-01",
          start_time: "00:00:00",
          end_date: "2016-01-01",
          end_time: "00:00:01"
        }
      }
    end
  end

  test "update should raise error when no time zone" do
    assert_raises RuntimeError do
      put "/outages/1", params: {
        outage: {
          title: "no time zone update",
          start_date: "2016-01-01",
          start_time: "00:00:00",
          end_date: "2016-01-01",
          end_time: "00:00:01"
        }
      }
    end
  end

  test "get one outage with a different cookie" do
    self.current_time_zone = tz = "Pacific/Pago_Pago"
    get "/outages/1"
    assert_response :success
    assert_not_nil(o = assigns(:outage))
    zone = ActiveSupport::TimeZone[tz]
    assert_equal zone.local(2015, 12, 30, 23, 0, 0), o.start_datetime_in_time_zone(tz)
    assert_select "p#start-time", "Start Time: 2015-12-30 23:00:00"
    assert_select "p#end-time", "End Time: 2015-12-30 23:00:01"
  end

  test "show error message for bad date" do
    self.current_time_zone = "Pacific/Pago_Pago"
    post "/outages", params: {
      outage: {
        title: "set time zone",
        start_date: "bad date",
        start_time: "00:00:00",
        end_date: "2016-01-01",
        end_time: "00:00:01"
      }
    }
    assert_select "#error-explanation", 1 do
      assert_select "li", 2 do |errors|
        assert_equal "Start date must be yyyy[-mm[-dd]]", errors[0].text
        assert_equal "End date must be after start date", errors[1].text
      end
    end
  end

  (OutagesController.calendar_views + [""]).map { |x| "/outages/" + x }.each do |action|
    test "#{action} without time zone should redirect" do
      get action.to_s
      assert_redirected_to Regexp.new(Regexp.quote(time_zone_path) + "*")
    end
  end
end
