class AddDescriptionToConfigurationItem < ActiveRecord::Migration[5.0]
  def change
    add_column :configuration_items, :description, :text
  end
end
