class CreatePredictions < ActiveRecord::Migration
  def change
    create_table :predictions do |t|
      t.string :city_id, index: true
      t.integer :source, index: true
      t.float :high
      t.float :low
      t.float :wind
      t.float :humidity
      t.float :precipitation
    end
  end
end
