class CreateIdeaTags < ActiveRecord::Migration[8.1]
  def change
    create_table :idea_tags do |t|
      t.references :idea, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end
    add_index :idea_tags, [:idea_id, :tag_id], unique: true
  end
end
