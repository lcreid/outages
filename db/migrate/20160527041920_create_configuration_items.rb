class CreateConfigurationItems < ActiveRecord::Migration[5.0]
  def change
    create_table :configuration_items do |t|
      t.string :name

      t.timestamps
    end
  end
end
