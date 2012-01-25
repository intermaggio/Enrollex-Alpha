class AddOidToOrganizationsUsers < ActiveRecord::Migration
  def change
    add_column :organizations_users, :organization_id, :integer

  end
end
