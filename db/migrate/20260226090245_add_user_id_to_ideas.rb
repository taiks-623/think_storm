class AddUserIdToIdeas < ActiveRecord::Migration[8.1]
  def change
    add_reference :ideas, :user, null: true, foreign_key: true
  end
end
