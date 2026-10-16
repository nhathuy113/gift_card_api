class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    enable_extension "citext"

    create_table :users do |t|
      t.citext  :email, null: false
      t.string  :password_digest, null: false
      t.string  :role, null: false
      t.string  :state, null: false, default: "active"
      t.decimal :payout_rate, precision: 5, scale: 2
      t.timestamps
    end

    add_index :users, :email, unique: true

    add_check_constraint :users, "role IN ('admin','client')", name: "users_role_check"
    add_check_constraint :users, "state IN ('active','inactive')", name: "users_state_check"
    add_check_constraint :users,
      "(role = 'client' AND payout_rate BETWEEN 0 AND 100) OR (role = 'admin' AND payout_rate IS NULL)",
      name: "users_payout_rate_check"
  end
end