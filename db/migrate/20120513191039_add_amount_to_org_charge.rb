class AddAmountToOrgCharge < ActiveRecord::Migration
  def change
    add_column :org_charges, :amount, :integer

  end
end
