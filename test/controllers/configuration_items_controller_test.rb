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

  test 'show error message for missing name' do
    post '/configuration_items', params: {
      configuration_item: {
        name: ''
      }
    }
    assert_select '#error-explanation', 1 do
      assert_select 'li', 1 do |errors|
        assert_equal "Name can't be blank", errors[0].text
      end
    end
  end
end
