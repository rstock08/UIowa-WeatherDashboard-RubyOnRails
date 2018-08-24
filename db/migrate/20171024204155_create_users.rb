class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :user_cell
      t.string :user_carrier
      t.string :user_id
      t.string :email
      t.string :session_token
      t.timestamps
    end
  end
end
