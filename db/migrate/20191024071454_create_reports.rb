class CreateReports < ActiveRecord::Migration[5.2]
  def change
    create_table :reports do |t|
      t.integer :kind, default: 0
      t.references :voter
      t.references :statement

      t.timestamps
    end
  end
end
