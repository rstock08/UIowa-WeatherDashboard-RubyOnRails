# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171208222509) do

  create_table "accuracy_metrics", force: :cascade do |t|
    t.integer  "darksky"
    t.integer  "weatherunderground"
    t.integer  "openweathermap"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notifications", force: :cascade do |t|
    t.string  "city_ids"
    t.string  "city_names"
    t.integer "time"
    t.integer "current"
    t.integer "daily"
    t.integer "hourly"
    t.integer "source"
    t.integer "user_id"
  end

  add_index "notifications", ["time"], name: "index_notifications_on_time"

  create_table "predictions", force: :cascade do |t|
    t.string  "city_id"
    t.integer "source"
    t.float   "high"
    t.float   "low"
    t.float   "wind"
    t.float   "humidity"
    t.float   "precipitation"
  end

  add_index "predictions", ["city_id"], name: "index_predictions_on_city_id"
  add_index "predictions", ["source"], name: "index_predictions_on_source"

  create_table "users", force: :cascade do |t|
    t.string   "user_id"
    t.string   "email"
    t.string   "session_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
    t.integer  "source_1"
    t.integer  "source_2"
    t.integer  "source_3"
    t.integer  "darksky"
    t.integer  "weatherunderground"
    t.integer  "openweathermap"
    t.string   "user_carrier"
    t.string   "user_cell"
  end

  create_table "weather_locations", force: :cascade do |t|
    t.string   "city_name"
    t.string   "city_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "weather_locations", ["city_id"], name: "index_weather_locations_on_city_id"

end
