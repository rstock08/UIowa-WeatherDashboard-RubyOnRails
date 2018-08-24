class AddUserCellToUsers < ActiveRecord::Migration
  def change
    add_column :users, :user_cell, :string
  end
end
