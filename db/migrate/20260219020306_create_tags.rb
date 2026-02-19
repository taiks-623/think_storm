class CreateTags < ActiveRecord::Migration[8.1]
  def change
    create_table :tags do |t|
      t.string :name, null: false
      t.references :brainstorm, null: false, foreign_key: true

      t.timestamps
    end
    add_index :tags, [:brainstorm_id, :name], unique: true
  end
end
