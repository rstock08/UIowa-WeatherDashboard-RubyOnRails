class AddRankingsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :source_1, :integer
    add_column :users, :source_2, :integer
    add_column :users, :source_3, :integer
  end
end
