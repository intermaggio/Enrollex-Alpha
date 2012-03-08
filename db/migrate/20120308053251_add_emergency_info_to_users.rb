class AddEmergencyInfoToUsers < ActiveRecord::Migration
  def change
    add_column :users, :ename, :string

    add_column :users, :enumber, :string

  end
end
