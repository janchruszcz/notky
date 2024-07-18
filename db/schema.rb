# frozen_string_literal: true

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

ActiveRecord::Schema[7.1].define(version: 20_240_717_120_038) do
  create_table 'lists', force: :cascade do |t|
    t.string 'title'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.integer 'row_order'
    t.integer 'user_id'
    t.index ['user_id'], name: 'index_lists_on_user_id'
  end

  create_table 'todos', force: :cascade do |t|
    t.string 'title'
    t.text 'description'
    t.boolean 'completed'
    t.datetime 'due_date'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.integer 'list_id'
    t.integer 'row_order'
    t.index ['list_id'], name: 'index_todos_on_list_id'
  end

  create_table 'users', force: :cascade do |t|
    t.string 'email', default: '', null: false
    t.string 'encrypted_password', default: '', null: false
    t.string 'reset_password_token'
    t.datetime 'reset_password_sent_at'
    t.datetime 'remember_created_at'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['email'], name: 'index_users_on_email', unique: true
    t.index ['reset_password_token'], name: 'index_users_on_reset_password_token', unique: true
  end

  add_foreign_key 'lists', 'users'
  add_foreign_key 'todos', 'lists'
end
