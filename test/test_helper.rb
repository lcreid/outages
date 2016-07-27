ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

# http://stackoverflow.com/questions/35496670/rails-5-testing-nomethoderror/35763171#35763171
class ActionDispatch::IntegrationTest
  include Rails::Controller::Testing::TestProcess
  include Rails::Controller::Testing::TemplateAssertions
  include Rails::Controller::Testing::Integration
end

# Added for Capybara
require "capybara/rails"

class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL

  # Reset sessions and driver between tests
  # Use super wherever this method is redefined in your individual test classes
  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
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

  Capybara::Webkit.configure do |config|
    config.allow_url("www.atlasestateagents.co.uk")
    config.allow_url("maxcdn.bootstrapcdn.com")
    config.allow_url("code.jquery.com")
  end
end
# End Capybara
