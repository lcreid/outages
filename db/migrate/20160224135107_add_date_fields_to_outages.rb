class AddDateFieldsToOutages < ActiveRecord::Migration[5.0]
  def change
    add_column :outages, :start_date, :string
    add_column :outages, :end_date, :string
  end
end
