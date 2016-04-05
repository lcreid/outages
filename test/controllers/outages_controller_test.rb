require 'test_helper'

class OutagesControllerTest < ActionDispatch::IntegrationTest
  NUMBER_OF_OUTAGE_FIXTURES = 6

  test 'should get index' do
    get '/outages'
    assert_response :success
    assert_not_nil assigns(:outages)
  end

  test 'should show ID 1' do
    get '/outages/1'
    assert_response :success
    assert_not_nil assigns(:outage)
  end

  test 'should get new outage' do
    get '/outages/new'
    assert_response :success
    assert_not_nil assigns(:outage)
  end

  test 'should edit outage 1' do
    get '/outages/1/edit'
    assert_response :success
    assert_not_nil(o = assigns(:outage))
    assert_equal 1, o.id
  end

  test 'should create outage' do
    assert_difference 'Outage.count' do
      post '/outages', params: {
        outage: {
          title: 'Functional 1',
          start_date: '2016-03-02',
          start_time: '18:37',
          end_date: '2016-03-02',
          end_time: '20:00',
          time_zone: 'Samoa'
        }
      }
    end
    assert_redirected_to outage_path(assigns(:outage))
  end

  test 'should update outage 1' do
    new_title = 'Happy New New Year Samoa'
    assert_no_difference 'Outage.count' do
      put '/outages/1', params: {
        outage: {
          title: new_title,
          start_date: '2016-01-01',
          start_time: '00:00:00',
          end_date: '2016-01-01',
          end_time: '00:00:01',
          time_zone: 'Samoa'
        }
      }
    end
    assert_not_nil(o = assigns(:outage))
    assert_equal new_title, o.title
    assert_redirected_to outage_path(o)
  end

  test 'should destroy outage 3' do
    assert_difference 'Outage.count', -1 do
      delete '/outages/3'
    end
    assert_redirected_to outages_path
  end

  test 'should get index with time_zone from cookie' do
    cookies['time_zone'] = tz = 'Pacific/Pago_Pago'
    get '/outages'
    assert_response :success
    assert_not_nil assigns(:outages)
    assert_select '#time-zone-setter option[selected]', tz
    assert_select 'tbody' do |table|
      assert_select table, 'tr', NUMBER_OF_OUTAGE_FIXTURES do |rows|
        assert_select rows[0], 'td' do |elements|
          assert_equal '2015-12-30 23:00:00', elements[1].text
          assert_equal '2015-12-30 23:00:01', elements[2].text
        end
        assert_select rows[1], 'td' do |elements|
          assert_equal '2015-12-31 13:00:00', elements[1].text
          assert_equal '2015-12-31 13:00:01', elements[2].text
        end
        assert_select rows[2], 'td' do |elements|
          assert_equal '2015-12-31 13:00:00', elements[1].text
          assert_equal '2015-12-31 13:00:01', elements[2].text
        end
      end
    end
  end

  test 'post/create should set cookie from time zone setter' do
    post '/outages', params: {
      outage: {
        title: 'set time zone',
        start_date: '2016-01-01',
        start_time: '00:00:00',
        end_date: '2016-01-01',
        end_time: '00:00:01',
        time_zone: tz = 'Pacific/Pago_Pago'
      }
    }
    assert_redirected_to outage_path(assigns(:outage))
    # OMG: The cookies key has to be a string in the test case.
    assert_equal tz, cookies['time_zone']
  end

  test 'put/update should set cookie from time zone setter' do
    put '/outages/1', params: {
      outage: {
        title: 'set time zone',
        start_date: '2016-01-01',
        start_time: '00:00:00',
        end_date: '2016-01-01',
        end_time: '00:00:01',
        time_zone: tz = 'Pacific/Pago_Pago'
      }
    }
    assert_redirected_to outage_path(assigns(:outage))
    # OMG: The cookies key has to be a string in the test case.
    assert_equal tz, cookies['time_zone']
  end

  test 'get one outage with a different cookie' do
    cookies['time_zone'] = tz = 'Pacific/Pago_Pago'
    get '/outages/1'
    assert_response :success
    assert_not_nil(o = assigns(:outage))
    zone = ActiveSupport::TimeZone[tz]
    assert_equal zone.local(2015, 12, 30, 23, 0, 0), o.start_datetime_in_time_zone(tz)
    assert_select 'p#start-time', 'Start Time: 2015-12-30 23:00:00'
    assert_select 'p#end-time', 'End Time: 2015-12-30 23:00:01'
  end
end
