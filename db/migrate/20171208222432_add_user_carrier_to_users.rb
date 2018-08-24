class AddUserCarrierToUsers < ActiveRecord::Migration
  def change
    add_column :users, :user_carrier, :string
  end
end
