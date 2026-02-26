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

ActiveRecord::Schema[8.1].define(version: 2026_02_26_090435) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "brainstorm_invitations", force: :cascade do |t|
    t.bigint "brainstorm_id", null: false
    t.datetime "created_at", null: false
    t.string "role", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.index ["brainstorm_id", "role"], name: "index_brainstorm_invitations_on_brainstorm_id_and_role", unique: true
    t.index ["brainstorm_id"], name: "index_brainstorm_invitations_on_brainstorm_id"
    t.index ["token"], name: "index_brainstorm_invitations_on_token", unique: true
  end

  create_table "brainstorm_members", force: :cascade do |t|
    t.bigint "brainstorm_id", null: false
    t.datetime "created_at", null: false
    t.string "role", default: "viewer", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["brainstorm_id", "user_id"], name: "index_brainstorm_members_on_brainstorm_id_and_user_id", unique: true
    t.index ["brainstorm_id"], name: "index_brainstorm_members_on_brainstorm_id"
    t.index ["user_id"], name: "index_brainstorm_members_on_user_id"
  end

  create_table "brainstorms", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_brainstorms_on_user_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.bigint "brainstorm_id", null: false
    t.datetime "created_at", null: false
    t.bigint "idea_id", null: false
    t.datetime "updated_at", null: false
    t.index ["brainstorm_id"], name: "index_conversations_on_brainstorm_id"
    t.index ["idea_id"], name: "index_conversations_on_idea_id"
  end

  create_table "evaluation_axes", force: :cascade do |t|
    t.bigint "brainstorm_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "position"
    t.datetime "updated_at", null: false
    t.index ["brainstorm_id"], name: "index_evaluation_axes_on_brainstorm_id"
  end

  create_table "evaluations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "evaluation_axis_id", null: false
    t.bigint "idea_id", null: false
    t.integer "score", null: false
    t.datetime "updated_at", null: false
    t.index ["evaluation_axis_id"], name: "index_evaluations_on_evaluation_axis_id"
    t.index ["idea_id", "evaluation_axis_id"], name: "index_evaluations_on_idea_id_and_evaluation_axis_id", unique: true
    t.index ["idea_id"], name: "index_evaluations_on_idea_id"
  end

  create_table "groups", force: :cascade do |t|
    t.bigint "brainstorm_id", null: false
    t.string "color"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "position"
    t.datetime "updated_at", null: false
    t.index ["brainstorm_id"], name: "index_groups_on_brainstorm_id"
    t.index ["position"], name: "index_groups_on_position"
  end

  create_table "idea_groups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "group_id", null: false
    t.bigint "idea_id", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_idea_groups_on_group_id"
    t.index ["idea_id", "group_id"], name: "index_idea_groups_on_idea_id_and_group_id", unique: true
    t.index ["idea_id"], name: "index_idea_groups_on_idea_id"
  end

  create_table "idea_tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "idea_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "updated_at", null: false
    t.index ["idea_id", "tag_id"], name: "index_idea_tags_on_idea_id_and_tag_id", unique: true
    t.index ["idea_id"], name: "index_idea_tags_on_idea_id"
    t.index ["tag_id"], name: "index_idea_tags_on_tag_id"
  end

  create_table "ideas", force: :cascade do |t|
    t.bigint "brainstorm_id", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.text "memo"
    t.integer "position"
    t.string "source", default: "user", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["brainstorm_id"], name: "index_ideas_on_brainstorm_id"
    t.index ["position"], name: "index_ideas_on_position"
    t.index ["user_id"], name: "index_ideas_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.text "content"
    t.bigint "conversation_id", null: false
    t.datetime "created_at", null: false
    t.string "role"
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
  end

  create_table "tags", force: :cascade do |t|
    t.bigint "brainstorm_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["brainstorm_id", "name"], name: "index_tags_on_brainstorm_id_and_name", unique: true
    t.index ["brainstorm_id"], name: "index_tags_on_brainstorm_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "provider"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "uid"
    t.string "unconfirmed_email"
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "brainstorm_invitations", "brainstorms"
  add_foreign_key "brainstorm_members", "brainstorms"
  add_foreign_key "brainstorm_members", "users"
  add_foreign_key "brainstorms", "users"
  add_foreign_key "conversations", "brainstorms"
  add_foreign_key "conversations", "ideas"
  add_foreign_key "evaluation_axes", "brainstorms"
  add_foreign_key "evaluations", "evaluation_axes", column: "evaluation_axis_id"
  add_foreign_key "evaluations", "ideas"
  add_foreign_key "groups", "brainstorms"
  add_foreign_key "idea_groups", "groups"
  add_foreign_key "idea_groups", "ideas"
  add_foreign_key "idea_tags", "ideas"
  add_foreign_key "idea_tags", "tags"
  add_foreign_key "ideas", "brainstorms"
  add_foreign_key "ideas", "users"
  add_foreign_key "messages", "conversations"
  add_foreign_key "tags", "brainstorms"
end
