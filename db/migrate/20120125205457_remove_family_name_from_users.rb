class RemoveFamilyNameFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :family_name
        remove_column :users, :parent_name
      end

  def down
    add_column :users, :parent_name, :string
    add_column :users, :family_name, :string
  end
end
