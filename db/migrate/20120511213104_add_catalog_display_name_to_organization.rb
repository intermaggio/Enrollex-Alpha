class AddCatalogDisplayNameToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :catalogDisplayName, :string, default: 'Course Catalog'

  end
end
