# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20081002163437) do

  create_table "bets", :force => true do |t|
    t.integer  "line_id",                             :null => false
    t.float    "desired_amount",     :default => 0.0
    t.float    "outstanding_amount", :default => 0.0
    t.float    "wagered_amount",     :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bets", ["line_id"], :name => "index_bets_on_line_id"

  create_table "games", :force => true do |t|
    t.string   "home_team",  :default => "", :null => false
    t.string   "away_team",  :default => "", :null => false
    t.datetime "event_dt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "home_score"
    t.integer  "away_score"
    t.integer  "period_id"
  end

  add_index "games", ["period_id"], :name => "index_games_on_period_id"
  add_index "games", ["id"], :name => "index_games_on_id"

  create_table "line_sets", :force => true do |t|
    t.integer  "game_id",            :null => false
    t.float    "spread"
    t.float    "return_from_dollar"
    t.string   "status"
    t.integer  "site_id"
    t.datetime "expire_dt"
    t.string   "team"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lines", :force => true do |t|
    t.integer  "game_id",            :null => false
    t.float    "spread"
    t.float    "return_from_dollar"
    t.string   "status"
    t.integer  "site_id"
    t.datetime "expire_dt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "team"
    t.datetime "effective_dt"
    t.integer  "line_set_id"
  end

  add_index "lines", ["game_id"], :name => "index_lines_on_game_id"
  add_index "lines", ["line_set_id"], :name => "index_lines_on_line_set_id"
  add_index "lines", ["id"], :name => "index_lines_on_id"

  create_table "passwords", :force => true do |t|
    t.integer  "user_id"
    t.string   "reset_code"
    t.datetime "expiration_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "periods", :force => true do |t|
    t.string   "name",       :default => "", :null => false
    t.datetime "start_dt"
    t.datetime "end_dt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string "name"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :default => "", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "sites", :force => true do |t|
    t.string   "name",       :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sites", ["id"], :name => "index_sites_on_id"

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "name",                      :limit => 100, :default => ""
    t.string   "email",                     :limit => 100
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "remember_token",            :limit => 40
    t.string   "activation_code",           :limit => 40
    t.string   "state",                                    :default => "passive"
    t.datetime "remember_token_expires_at"
    t.datetime "activated_at"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

end
