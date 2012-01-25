class AddUidToOrganizationsAdmins < ActiveRecord::Migration
  def change
    add_column :organizations_admins, :user_id, :integer

    add_column :organizations_admins, :organization_id, :integer

  end
end
