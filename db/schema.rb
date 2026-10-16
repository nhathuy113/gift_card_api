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

ActiveRecord::Schema[8.1].define(version: 2026_10_16_051700) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_catalog.plpgsql"

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
    t.check_constraint "role::text = ANY (ARRAY['admin'::character varying, 'client'::character varying]::text[])", name: "users_role_check"
    t.check_constraint "state::text = ANY (ARRAY['active'::character varying, 'inactive'::character varying]::text[])", name: "users_state_check"
  end
end
