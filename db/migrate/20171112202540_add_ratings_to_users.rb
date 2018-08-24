class AddRatingsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :darksky, :integer
    add_column :users, :weatherunderground, :integer
    add_column :users, :openweathermap, :integer
  end
end
