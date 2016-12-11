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

ActiveRecord::Schema.define(version: 20161211001331) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "elections", force: :cascade do |t|
    t.string   "start_date"
    t.string   "end_date"
    t.string   "total_electoral_votes"
    t.string   "total_popular_votes"
    t.string   "voter_turnout"
    t.string   "number_of_states_that_voted"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "nominees", force: :cascade do |t|
    t.string   "num_popular_votes"
    t.string   "num_electoral_votes"
    t.string   "result"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "person_id"
    t.integer  "election_id"
    t.integer  "party_id"
  end

  create_table "parties", force: :cascade do |t|
    t.string   "party_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "people", force: :cascade do |t|
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.string   "birth_date"
    t.string   "date_of_death"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "polls", force: :cascade do |t|
    t.string   "polling_percentage"
    t.string   "date_poll_taken"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "nominee_id"
  end

  create_table "populations", force: :cascade do |t|
    t.string   "year"
    t.string   "us_population"
    t.string   "growth_percent"
    t.string   "annual_change"
    t.string   "data_note"
    t.string   "source_link"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "presidents", force: :cascade do |t|
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "person_id"
    t.integer  "election_id"
    t.integer  "nominee_id"
    t.integer  "party_id"
    t.text     "description"
  end

  add_foreign_key "nominees", "elections"
  add_foreign_key "nominees", "parties"
  add_foreign_key "nominees", "people"
  add_foreign_key "polls", "nominees"
  add_foreign_key "presidents", "elections"
  add_foreign_key "presidents", "nominees"
  add_foreign_key "presidents", "parties"
  add_foreign_key "presidents", "people"
end
