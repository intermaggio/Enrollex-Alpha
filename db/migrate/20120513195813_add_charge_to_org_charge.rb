class AddChargeToOrgCharge < ActiveRecord::Migration
  def change
    add_column :org_charges, :charged_at, :datetime

  end
end
