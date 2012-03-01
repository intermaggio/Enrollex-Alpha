class AddTitleToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :welcome_title, :string

  end
end
