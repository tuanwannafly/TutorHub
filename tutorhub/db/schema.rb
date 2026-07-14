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

ActiveRecord::Schema[7.1].define(version: 2026_07_10_000005) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "availabilities", force: :cascade do |t|
    t.bigint "tutor_profile_id", null: false
    t.integer "day_of_week", null: false
    t.time "start_time", null: false
    t.time "end_time", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tutor_profile_id", "day_of_week"], name: "idx_availabilities_on_tutor_and_day"
    t.index ["tutor_profile_id"], name: "index_availabilities_on_tutor_profile_id"
  end

  create_table "bookings", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "tutor_id", null: false
    t.date "booking_date", null: false
    t.time "start_time", null: false
    t.time "end_time", null: false
    t.integer "status", default: 0, null: false
    t.decimal "total_amount", precision: 8, scale: 2, default: "0.0", null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["student_id", "status"], name: "index_bookings_on_student_id_and_status"
    t.index ["student_id"], name: "index_bookings_on_student_id"
    t.index ["tutor_id", "booking_date", "start_time"], name: "idx_bookings_unique_slot", unique: true
    t.index ["tutor_id"], name: "index_bookings_on_tutor_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "booking_id", null: false
    t.bigint "reviewer_id", null: false
    t.integer "rating", null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_reviews_on_booking_id", unique: true
    t.index ["reviewer_id"], name: "index_reviews_on_reviewer_id"
  end

  create_table "tutor_profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "subject", null: false
    t.string "headline"
    t.decimal "hourly_rate", precision: 8, scale: 2, default: "0.0", null: false
    t.text "bio"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_tutor_profiles_on_user_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "name", null: false
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((email)::text)", name: "index_users_on_lower_email", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "availabilities", "tutor_profiles"
  add_foreign_key "bookings", "users", column: "student_id"
  add_foreign_key "bookings", "users", column: "tutor_id"
  add_foreign_key "reviews", "bookings"
  add_foreign_key "reviews", "users", column: "reviewer_id"
  add_foreign_key "tutor_profiles", "users"
end
