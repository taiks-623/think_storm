class CreateEvaluationAxes < ActiveRecord::Migration[8.1]
  def change
    create_table :evaluation_axes do |t|
      t.references :brainstorm, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :position

      t.timestamps
    end
  end
end
