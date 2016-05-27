require 'test_helper'

class ConfigurationItemsControllerTest < ActionDispatch::IntegrationTest
  test 'should create configuration_item' do
    assert_difference 'ConfigurationItem.count' do
      post '/configuration_items', params: {
        configuration_item: {
          name: 'CI 1'
        }
      }
    end
    assert_redirected_to configuration_item_path(assigns(:configuration_item))
  end
end
