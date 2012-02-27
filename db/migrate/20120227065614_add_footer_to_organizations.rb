class AddFooterToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :footer, :text

  end
end
