# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_10_16_100800) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_catalog.plpgsql"

  create_table "brands", force: :cascade do |t|
    t.string "name", null: false
    t.string "state", default: "active", null: false
    t.jsonb "custom_fields", default: [], null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_brands_on_name", unique: true
    t.check_constraint "jsonb_array_length(custom_fields) <= 5", name: "brands_custom_fields_max5"
    t.check_constraint "state::text = ANY (ARRAY['active'::character varying, 'inactive'::character varying]::text[])", name: "brands_state_check"
  end

  create_table "cards", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.bigint "product_id", null: false
    t.string "activation_number", null: false
    t.string "pin"
    t.string "status", default: "issued", null: false
    t.integer "price_value", null: false
    t.decimal "payout_rate", precision: 5, scale: 2, null: false
    t.datetime "issued_at", null: false
    t.datetime "cancelled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activation_number"], name: "index_cards_on_activation_number", unique: true
    t.index ["client_id"], name: "index_cards_on_client_id"
    t.index ["product_id"], name: "index_cards_on_product_id"
    t.check_constraint "status::text = 'issued'::text AND cancelled_at IS NULL OR status::text = 'cancelled'::text AND cancelled_at IS NOT NULL", name: "cards_cancelled_at_check"
    t.check_constraint "status::text = ANY (ARRAY['issued'::character varying, 'cancelled'::character varying]::text[])", name: "cards_status_check"
  end

  create_table "client_accessible_products", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.bigint "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id", "product_id"], name: "index_client_accessible_products_on_client_id_and_product_id", unique: true
    t.index ["client_id"], name: "index_client_accessible_products_on_client_id"
    t.index ["product_id"], name: "index_client_accessible_products_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.bigint "brand_id", null: false
    t.string "name", null: false
    t.integer "price_value", null: false
    t.string "state", default: "active", null: false
    t.jsonb "custom_fields", default: [], null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["brand_id"], name: "index_products_on_brand_id"
    t.check_constraint "jsonb_array_length(custom_fields) <= 5", name: "products_custom_fields_max5"
    t.check_constraint "price_value > 0", name: "products_price_value_positive"
    t.check_constraint "state::text = ANY (ARRAY['active'::character varying, 'inactive'::character varying]::text[])", name: "products_state_check"
  end

  create_table "users", force: :cascade do |t|
    t.citext "email", null: false
    t.string "password_digest", null: false
    t.string "role", null: false
    t.string "state", default: "active", null: false
    t.decimal "payout_rate", precision: 5, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.check_constraint "role::text = 'client'::text AND payout_rate >= 0::numeric AND payout_rate <= 100::numeric OR role::text = 'admin'::text AND payout_rate IS NULL", name: "users_payout_rate_check"
    t.check_constraint "role::text = ANY (ARRAY['admin'::character varying::text, 'client'::character varying::text])", name: "users_role_check"
    t.check_constraint "state::text = ANY (ARRAY['active'::character varying::text, 'inactive'::character varying::text])", name: "users_state_check"
  end

  add_foreign_key "cards", "products"
  add_foreign_key "cards", "users", column: "client_id"
  add_foreign_key "client_accessible_products", "products"
  add_foreign_key "client_accessible_products", "users", column: "client_id"
  add_foreign_key "products", "brands"
end
