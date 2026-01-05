class CreateIdeaGroups < ActiveRecord::Migration[8.1]
  def change
    create_table :idea_groups do |t|
      t.references :idea, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true

      t.timestamps
    end
    
    # 同じアイデアが同じグループに複数回登録されないように
    add_index :idea_groups, [:idea_id, :group_id], unique: true
  end
end
