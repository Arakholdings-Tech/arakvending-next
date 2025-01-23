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

ActiveRecord::Schema[8.0].define(version: 2025_01_23_161431) do
  create_table "machines", force: :cascade do |t|
    t.string "machine_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["machine_id"], name: "index_machines_on_machine_id", unique: true
  end

  create_table "payments", force: :cascade do |t|
    t.integer "product_id", null: false
    t.decimal "amount"
    t.string "status"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "seq_number"
    t.index ["product_id"], name: "index_payments_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.integer "machine_id", null: false
    t.string "name"
    t.decimal "price"
    t.integer "selection"
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["machine_id"], name: "index_products_on_machine_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.string "transaction_id"
    t.string "status", default: "pending"
    t.decimal "amount"
    t.integer "payment_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payment_id"], name: "index_transactions_on_payment_id"
    t.index ["transaction_id"], name: "index_transactions_on_transaction_id", unique: true
  end

  add_foreign_key "payments", "products"
  add_foreign_key "products", "machines"
  add_foreign_key "transactions", "payments"
end
