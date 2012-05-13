class AddOrgIdToOrgCharge < ActiveRecord::Migration
  def change
    add_column :org_charges, :organization_id, :integer

  end
end
