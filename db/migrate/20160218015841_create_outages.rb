class CreateOutages < ActiveRecord::Migration[5.0]
  def change
    create_table :outages do |t|
      t.string :title
      t.string :start_time
      t.string :end_time
      t.string :time_zone
      t.text :description

      t.timestamps
    end
  end
end
