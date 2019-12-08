class ChangeVoteCountName < ActiveRecord::Migration[5.2]
  def change
    rename_column :statements, :vote_count, :agree_count
  end
end
