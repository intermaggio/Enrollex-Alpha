class AddUidToOrganizationsUsers < ActiveRecord::Migration
  def change
    add_column :organizations_users, :user_id, :integer

  end
end
