class CreateBrandsAndProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :brands do |t|
      t.string :name, null: false
      t.string :state, null: false, default: "active"
      t.jsonb  :custom_fields, null: false, default: []
      t.timestamps
    end
    add_index :brands, :name, unique: true
    add_check_constraint :brands, "state IN ('active','inactive')", name: "brands_state_check"
    add_check_constraint :brands, "jsonb_array_length(custom_fields) <= 5", name: "brands_custom_fields_max5"

    create_table :products do |t|
      t.references :brand, null: false, foreign_key: true
      t.string  :name, null: false
      t.integer :price_value, null: false
      t.string  :state, null: false, default: "active"
      t.jsonb   :custom_fields, null: false, default: []
      t.timestamps
    end
    add_check_constraint :products, "price_value > 0", name: "products_price_value_positive"
    add_check_constraint :products, "state IN ('active','inactive')", name: "products_state_check"
    add_check_constraint :products, "jsonb_array_length(custom_fields) <= 5", name: "products_custom_fields_max5"
  end
end
