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

ActiveRecord::Schema.define(version: 20150416113036) do

  create_table "perfdashboard_context_infos", force: :cascade do |t|
    t.integer  "context_id"
    t.string   "description"
    t.float    "duration"
    t.datetime "time"
    t.text     "data"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "perfdashboard_context_infos", ["context_id"], name: "index_perfdashboard_context_infos_on_context_id"

  create_table "perfdashboard_contexts", force: :cascade do |t|
    t.integer  "context_uid"
    t.string   "type"
    t.string   "name"
    t.integer  "request_id"
    t.integer  "context_data_count"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "perfdashboard_contexts", ["request_id"], name: "index_perfdashboard_contexts_on_request_id"

  create_table "perfdashboard_requests", force: :cascade do |t|
    t.string   "request_uid"
    t.datetime "time"
    t.float    "duration"
    t.string   "controller"
    t.string   "action"
    t.string   "path"
    t.boolean  "error",         default: false
    t.boolean  "xhr",           default: false
    t.string   "format",        default: "html"
    t.float    "view_duration"
    t.float    "db_duration"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "posts", force: :cascade do |t|
    t.string   "subject"
    t.text     "content"
    t.integer  "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "posts", ["author_id"], name: "index_posts_on_author_id"

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "password_digest"
    t.string   "firstname"
    t.string   "lastname"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

end
