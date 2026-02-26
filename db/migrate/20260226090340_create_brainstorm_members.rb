class CreateBrainstormMembers < ActiveRecord::Migration[8.1]
  def change
    create_table :brainstorm_members do |t|
      t.references :brainstorm, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :role, null: false, default: "viewer"

      t.timestamps
    end

    add_index :brainstorm_members, [:brainstorm_id, :user_id], unique: true
  end
end
