class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string :city_ids
      t.string :city_names
      t.integer :time, index: true
      t.integer :current
      t.integer :daily
      t.integer :hourly
      t.integer :source
      t.belongs_to :user
    end
  end
end
