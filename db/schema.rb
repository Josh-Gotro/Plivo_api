
ActiveRecord::Schema.define(version: 2020_10_23_160133) do
  enable_extension "plpgsql"

  create_table "messages", force: :cascade do |t|
    t.string "MessageUUID"
    t.string "Text"
    t.bigint "From"
    t.bigint "To"
    t.boolean "isoutgoing"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end
end
