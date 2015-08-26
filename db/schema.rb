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

ActiveRecord::Schema.define(version: 20150826121100) do

  create_table "images", force: :cascade do |t|
    t.string   "url"
    t.string   "created_time"
    t.string   "month"
    t.string   "day"
    t.string   "year"
    t.string   "caption"
    t.string   "instagram_id"
    t.string   "instagram_link"
    t.string   "latitude"
    t.string   "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "thumbnail"
    t.string   "lowres"
    t.string   "date"
    t.boolean  "tag",            default: false
    t.boolean  "deleted",        default: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.string   "accesstoken"
    t.string   "instagram_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password"
  end

end
