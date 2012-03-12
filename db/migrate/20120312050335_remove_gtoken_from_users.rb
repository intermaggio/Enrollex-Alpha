class RemoveGtokenFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :gtoken
      end

  def down
    add_column :users, :gtoken, :string
  end
end
