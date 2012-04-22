class AddTimezoneToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :timezone, :string

  end
end
