class CreateCards < ActiveRecord::Migration[8.1]
  def change
    create_table :cards do |t|
      t.references :client, null: false, foreign_key: { to_table: :users }
      t.references :product, null: false, foreign_key: true
      t.string :activation_number, null: false
      t.string :pin
      t.string :status, null: false, default: "issued"
      t.integer :price_value, null: false
      t.decimal :payout_rate, precision: 5, scale: 2, null: false
      t.datetime :issued_at, null: false
      t.datetime :cancelled_at
      t.timestamps
    end
    add_index :cards, :activation_number, unique: true
    add_check_constraint :cards, "status IN ('issued','cancelled')", name: "cards_status_check"
    add_check_constraint :cards,
      "(status = 'issued' AND cancelled_at IS NULL) OR (status = 'cancelled' AND cancelled_at IS NOT NULL)",
      name: "cards_cancelled_at_check"
  end
end
