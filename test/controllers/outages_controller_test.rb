require 'test_helper'

class OutagesControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  test 'should get index' do
    get '/outages'
    assert_response :success
    assert_not_nil assigns(:outages)
  end

  test 'should show ID 1' do
    get('/outages/1')
    assert_response :success
    assert_not_nil assigns(:outage)
  end

  test 'should get new outage' do
    get "/outages/new"
    assert_response :success
    assert_not_nil assigns(:outage)
  end

  test 'should edit outage 1' do
    get "/outages/1/edit"
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
    new_title = "Happy New New Year Samoa"
    assert_no_difference 'Outage.count' do
      put '/outages/1', params: {
        outage: {
          title: new_title,
          start_date: "2016-01-01",
          start_time: "00:00:00",
          end_date: "2016-01-01",
          end_time: "00:00:01",
          time_zone: "Samoa"
        }
      }
    end
    assert_not_nil(o = assigns(:outage))
    assert_equal new_title, o.title
    assert_redirected_to outage_path(o)
  end

  test "should destroy outage 3" do
    assert_difference 'Outage.count', -1 do
      delete '/outages/3'
    end
    assert_redirected_to outages_path
  end
end
