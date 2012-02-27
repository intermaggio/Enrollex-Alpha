class AddDimensionsToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :banner_width, :string

    add_column :organizations, :banner_height, :string

  end
end
