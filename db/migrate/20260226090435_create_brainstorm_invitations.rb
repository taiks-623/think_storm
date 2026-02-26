class CreateBrainstormInvitations < ActiveRecord::Migration[8.1]
  def change
    create_table :brainstorm_invitations do |t|
      t.references :brainstorm, null: false, foreign_key: true
      t.string :token, null: false
      t.string :role, null: false

      t.timestamps
    end

    add_index :brainstorm_invitations, :token, unique: true
    add_index :brainstorm_invitations, [:brainstorm_id, :role], unique: true
  end
end
