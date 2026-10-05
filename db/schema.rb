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

ActiveRecord::Schema[8.0].define(version: 2026_10_05_000004) do
  create_table "job_applications", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "company", null: false
    t.string "position", null: false
    t.string "posting_url"
    t.integer "salary_from"
    t.integer "salary_to"
    t.string "status", default: "wishlist", null: false
    t.date "applied_on"
    t.datetime "status_changed_at"
    t.string "next_step"
    t.date "next_step_on"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "status"], name: "index_job_applications_on_user_id_and_status"
    t.index ["user_id"], name: "index_job_applications_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "status_changes", force: :cascade do |t|
    t.integer "job_application_id", null: false
    t.string "from_status"
    t.string "to_status", null: false
    t.datetime "created_at", null: false
    t.index ["job_application_id"], name: "index_status_changes_on_job_application_id"
    t.index ["to_status"], name: "index_status_changes_on_to_status"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "job_applications", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "status_changes", "job_applications"
end
