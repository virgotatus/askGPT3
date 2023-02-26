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

ActiveRecord::Schema[7.0].define(version: 2023_02_26_043755) do
  create_table "details", force: :cascade do |t|
    t.string "imgname"
    t.string "imglink"
    t.text "description"
    t.integer "prompt_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "alter_questions", default: "wish me lucky and happy"
    t.index ["prompt_id"], name: "index_details_on_prompt_id"
  end

  create_table "ideas", force: :cascade do |t|
    t.string "city"
    t.string "thing"
    t.string "oblique"
    t.string "style"
    t.text "answer"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "prompts", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "replies", force: :cascade do |t|
    t.text "body"
    t.integer "prompt_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "radio_url"
    t.index ["prompt_id"], name: "index_replies_on_prompt_id"
  end

  add_foreign_key "details", "prompts"
  add_foreign_key "replies", "prompts"
end
