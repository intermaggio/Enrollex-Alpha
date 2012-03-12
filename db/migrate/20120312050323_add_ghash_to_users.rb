class AddGhashToUsers < ActiveRecord::Migration
  def change
    add_column :users, :ghash, :string

  end
end
