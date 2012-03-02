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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120302180550) do

  create_table "campers", :force => true do |t|
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "user_id"
    t.text     "health_info"
    t.date     "birthday"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "street"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "gender"
  end

  create_table "campers_courses", :force => true do |t|
    t.integer "camper_id"
    t.integer "course_id"
  end

  create_table "charges", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "course_id"
  end

  create_table "courses", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.string   "image"
    t.text     "description"
    t.boolean  "featured"
    t.string   "lowname"
    t.string   "status"
    t.integer  "organization_id"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.text     "notes"
    t.integer  "start_range"
    t.integer  "end_range"
    t.integer  "suite"
    t.integer  "room"
    t.string   "range_type"
    t.string   "location_name"
    t.boolean  "published"
    t.text     "which_days"
    t.boolean  "daily"
    t.text     "time_exceptions"
    t.time     "default_start"
    t.time     "default_end"
    t.string   "date_string"
    t.date     "published_at"
    t.date     "start_date"
    t.integer  "price"
    t.text     "reg_description"
    t.string   "reg_link"
    t.boolean  "show_map",        :default => true
    t.integer  "max_campers"
  end

  create_table "days", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.time     "start_time"
    t.time     "end_time"
    t.date     "date"
    t.integer  "course_id"
  end

  create_table "instructors_courses", :force => true do |t|
    t.integer "course_id"
    t.integer "user_id"
  end

  create_table "instructors_organizations", :force => true do |t|
    t.integer "user_id"
    t.integer "organization_id"
  end

  create_table "organizations", :force => true do |t|
    t.string   "name"
    t.text     "desc"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.string   "subname"
    t.string   "unit_name",          :default => "camper"
    t.string   "signup_options"
    t.string   "banner"
    t.string   "banner_height"
    t.text     "welcome_message"
    t.string   "color"
    t.text     "footer"
    t.string   "stripe_secret"
    t.string   "stripe_publishable"
    t.string   "welcome_title"
  end

  create_table "organizations_admins", :force => true do |t|
    t.integer "user_id"
    t.integer "organization_id"
  end

  create_table "organizations_users", :force => true do |t|
    t.integer "organization_id"
    t.integer "user_id"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                           :null => false
    t.string   "crypted_password"
    t.string   "salt"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.string   "remember_me_token"
    t.datetime "remember_me_token_expires_at"
    t.string   "reset_password_token"
    t.datetime "reset_password_token_expires_at"
    t.datetime "reset_password_email_sent_at"
    t.string   "first_name"
    t.string   "last_name"
    t.date     "birthday"
    t.string   "phone"
    t.string   "street"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.text     "health_info"
    t.string   "image"
    t.text     "bio"
    t.string   "utype"
    t.string   "gender"
  end

  add_index "users", ["remember_me_token"], :name => "index_users_on_remember_me_token"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token"

end
