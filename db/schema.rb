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

ActiveRecord::Schema.define(version: 20150630173255) do

  create_table "event_owners", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password_hash"
    t.string   "event_name"
    t.text     "description"
    t.integer  "ticket_price"
    t.string   "wepay_access_token"
    t.integer  "wepay_account_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.text     "attendee_list"
    t.datetime "from_event"
    t.datetime "to_event"
    t.text     "location"
  end

end
