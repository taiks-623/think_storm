class CreateIdeas < ActiveRecord::Migration[8.1]
  def change
    create_table :ideas do |t|
      t.references :brainstorm, null: false, foreign_key: true
      t.text :content, null: false
      t.string :source, null: false, default: 'user'
      t.text :memo
      t.integer :position

      t.timestamps
    end
    
    add_index :ideas, :position
  end
end
