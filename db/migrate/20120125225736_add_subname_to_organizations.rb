class AddSubnameToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :subname, :string

  end
end
