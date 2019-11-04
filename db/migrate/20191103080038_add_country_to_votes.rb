class AddCountryToVotes < ActiveRecord::Migration[5.2]
  def change
    add_column :votes, :country, :string
  end
end
