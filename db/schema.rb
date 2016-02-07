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

ActiveRecord::Schema.define(version: 20160206100144) do

  create_table "answers", force: :cascade do |t|
    t.datetime "creation_date"
    t.datetime "last_activity_date"
    t.integer  "rating"
    t.text     "body"
    t.integer  "comment_count"
    t.integer  "owner_id"
    t.integer  "question_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "answers", ["owner_id"], name: "index_answers_on_owner_id"
  add_index "answers", ["question_id"], name: "index_answers_on_question_id"

  create_table "comments", force: :cascade do |t|
    t.datetime "creation_date"
    t.integer  "rating"
    t.text     "text"
    t.integer  "owner_id"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "comments", ["owner_id"], name: "index_comments_on_owner_id"

  create_table "questions", force: :cascade do |t|
    t.datetime "creation_date"
    t.datetime "last_activity_date"
    t.integer  "rating"
    t.text     "body"
    t.integer  "comment_count"
    t.integer  "answer_count"
    t.string   "tags"
    t.string   "title"
    t.integer  "favorite_count"
    t.integer  "view_count"
    t.datetime "last_edit_date"
    t.integer  "accepted_answer_id"
    t.integer  "last_editor_id"
    t.integer  "owner_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "questions", ["accepted_answer_id"], name: "index_questions_on_accepted_answer_id"
  add_index "questions", ["last_editor_id"], name: "index_questions_on_last_editor_id"
  add_index "questions", ["owner_id"], name: "index_questions_on_owner_id"

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.datetime "date_joined"
    t.string   "display_name"
    t.string   "url"
    t.string   "location"
    t.text     "description"
    t.integer  "views"
    t.integer  "votes_up"
    t.integer  "votes_down"
    t.integer  "age"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

end
