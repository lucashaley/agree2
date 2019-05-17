class CreateStatements < ActiveRecord::Migration[5.2]
  def change
    create_table :statements do |t|
      t.text :content, index: true
      t.references :author, foreign_key: { to_table: :voters }
      t.references :parent, index: true

      t.timestamps
    end
  end
end
