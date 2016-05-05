require 'test_helper'

class TimeZoneTest < ActionDispatch::IntegrationTest
  def setup
    Capybara.current_driver = Capybara.javascript_driver # :webkit via test.rb

    # @headless = Headless.new
    # @headless.start
  end

  # def teardown
  #   @headless.destroy
  #   super # For Capybara
  # end

  test 'should use local time zone' do
    assert_nothing_raised do
      visit '/outages'
    end
    assert_nothing_raised do
      visit '/outages/1'
    end
  end
end
