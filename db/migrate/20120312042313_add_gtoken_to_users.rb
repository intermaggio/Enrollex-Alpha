class AddGtokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :gtoken, :string

  end
end
