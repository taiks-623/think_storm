class CreateGroups < ActiveRecord::Migration[8.1]
  def change
    create_table :groups do |t|
      t.references :brainstorm, null: false, foreign_key: true
      t.string :name, null: false
      t.string :color
      t.integer :position

      t.timestamps
    end
    
    add_index :groups, :position
  end
end
