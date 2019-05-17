class CreateStatementHierarchies < ActiveRecord::Migration[5.0]
  def change
    create_table :statement_hierarchies, id: false do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
    end

    add_index :statement_hierarchies, [:ancestor_id, :descendant_id, :generations],
      unique: true,
      name: "statement_anc_desc_idx"

    add_index :statement_hierarchies, [:descendant_id],
      name: "statement_desc_idx"
  end
end
