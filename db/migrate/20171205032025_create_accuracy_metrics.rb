class CreateAccuracyMetrics < ActiveRecord::Migration
  def change
    create_table :accuracy_metrics do |t|
      t.integer :darksky
      t.integer :weatherunderground
      t.integer :openweathermap
      t.timestamps
    end
  end
end
