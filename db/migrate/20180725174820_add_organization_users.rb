class AddOrganizationUsers < ActiveRecord::Migration[5.2]
  def change
    create_table "organization_users", id: :serial, force: :cascade do |t|
      t.uuid "organization_id"
      t.uuid "user_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "status", default: "invited", null: false
      t.string "role", default: "regular_user", null: false
      t.datetime "last_invitation_sent_at"
      t.index ["organization_id", "user_id"], name: "index_organization_users_on_organization_id_and_user_id", unique: true
    end

    add_foreign_key :organization_users, :users
    add_foreign_key :organization_users, :organizations
  end
end
