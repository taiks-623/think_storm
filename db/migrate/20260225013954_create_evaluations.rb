class CreateEvaluations < ActiveRecord::Migration[8.1]
  def change
    create_table :evaluations do |t|
      t.references :idea, null: false, foreign_key: true
      t.references :evaluation_axis, null: false, foreign_key: { to_table: :evaluation_axes }
      t.integer :score, null: false

      t.timestamps
    end

    add_index :evaluations, [:idea_id, :evaluation_axis_id], unique: true
  end
end
