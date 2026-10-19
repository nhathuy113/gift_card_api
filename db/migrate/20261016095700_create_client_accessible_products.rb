class CreateClientAccessibleProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :client_accessible_products do |t|
      t.references :client, null: false, foreign_key: { to_table: :users }
      t.references :product, null: false, foreign_key: true
      t.timestamps
    end
    add_index :client_accessible_products, [:client_id, :product_id], unique: true
  end
end
