class RemovePhoneAddressFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :phone
        remove_column :users, :address
      end

  def down
    add_column :users, :address, :string
    add_column :users, :phone, :string
  end
end
