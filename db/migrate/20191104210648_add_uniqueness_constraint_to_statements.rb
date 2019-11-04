class AddUniquenessConstraintToStatements < ActiveRecord::Migration[5.2]
  def change
    remove_index :statements, :content
    add_index :statements, :content, unique: true
  end
end
