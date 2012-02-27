class RemoveWidthFromOrganizations < ActiveRecord::Migration
  def up
    remove_column :organizations, :banner_width
      end

  def down
    add_column :organizations, :banner_width, :string
  end
end
