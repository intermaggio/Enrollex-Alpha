class AddUnitNameToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :unit_name, :string, default: 'camper'

  end
end
