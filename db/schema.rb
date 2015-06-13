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

ActiveRecord::Schema.define(version: 20150613221755) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "live_blogs", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.string   "channel_id"
    t.string   "channel_name"
    t.boolean  "live"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.text     "text"
    t.integer  "user_id"
    t.datetime "timestamp"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "live_blog_id"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.integer  "cursor"
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "slack_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.string   "real_name"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

end
