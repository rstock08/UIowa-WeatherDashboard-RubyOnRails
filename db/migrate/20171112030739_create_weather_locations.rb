class CreateWeatherLocations < ActiveRecord::Migration
  def change
    create_table :weather_locations do |t|
      t.string :city_name
      t.string :city_id, index: true
      t.timestamps
      t.belongs_to :user
    end
  end
end