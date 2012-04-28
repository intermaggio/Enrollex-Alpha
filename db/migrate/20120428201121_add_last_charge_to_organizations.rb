class AddLastChargeToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :last_charge, :integer

  end
end
