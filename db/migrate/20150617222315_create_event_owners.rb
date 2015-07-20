class CreateEventOwners < ActiveRecord::Migration
  def change
    create_table :event_owners do |t|
      t.string :name
      t.string :email
      t.string :password_hash
      t.string :event_name
      t.text :description
      t.integer :ticket_price
      t.string :wepay_access_token
      t.integer :wepay_account_id

      t.timestamps null: false
    end
  end
end
