require 'test_helper'

class TimeZoneTest < ActionDispatch::IntegrationTest
  Capybara::Webkit.configure do |config|
    config.allow_url('www.atlasestateagents.co.uk')
    config.allow_url('maxcdn.bootstrapcdn.com')
    config.allow_url('code.jquery.com')
  end

  def driver_cookie(cookie_id)
    URI.decode(page.driver.cookies[cookie_id])
  end

  def setup
    Capybara.current_driver = Capybara.javascript_driver # :webkit via test.rb

    # @headless = Headless.new
    # @headless.start
  end

  # def teardown
  #   @headless.destroy
  #   super # For Capybara
  # end

  test "Get time zone from browser default when it's not set in cookie" do
    # page.driver.clear_cookies
    visit '/outages'
    assert_current_path(time_zone_path, only_path: true)
    click_on 'Submit'
    # The following line assumes that for testing the "browser" is in the
    # same time zone as the server. Should be a safe assumption.
    # puts page.driver.console_messages
    # TODO: Make this work in other time zones.
    # ActiveSupport::TimeZone[`cat /etc/timezone`.strip].name
    assert_equal  'America/Los_Angeles',
                  driver_cookie('time_zone')
    assert_current_path(outages_path)
    # Now that cookie is set, we should go straight to the page.
    visit '/outages'
    assert_current_path(outages_path)
  end

  test "User sets time zone" do
    visit '/outages/1'
    assert_current_path(time_zone_path, only_path: true)
    select (tz = 'Pacific/Pago_Pago'), from: 'time_zone_time_zone'
    click_on 'Submit'
    assert_equal tz, driver_cookie('time_zone')
    assert_current_path(outage_path(1))
  end

  test "Changing time zone changes time displayed" do
    visit outage_path(1)
    select 'America/Los_Angeles', from: 'time_zone_time_zone'
    click_on 'Submit'
    assert_current_path outage_path(1)
    find('#start-time').assert_text('2015-12-31 02:00:00')
    # TODO: Why doesn't the following work?
    # click_link '#set_time_zone'
    find('#set_time_zone').click
    assert_current_path(time_zone_path, only_path: true)
    select 'Pacific/Apia', from: 'time_zone_time_zone'
    click_on 'Submit'
    puts 'Time zone cookies via driver: ' + driver_cookie('time_zone')
    # puts 'Time zone cookies via Rails: ' + current_time_zone
    page.driver.console_messages.each { |m| puts m }
    # assert_equal current_time_zone, driver_cookie('time_zone')
    assert_current_path outage_path(1)
    find('#start-time').assert_text('2016-01-01 00:00:00')
  end

  test "Time zone setter starts with cookie value if set" do
    skip
  end
end
