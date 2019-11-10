class AddVoteCountToStatements < ActiveRecord::Migration[5.2]
  def change
    add_column :statements, :vote_count, :integer
  end
end
