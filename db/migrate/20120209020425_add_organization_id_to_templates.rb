class AddOrganizationIdToTemplates < ActiveRecord::Migration
  def change
    add_column :templates, :organization_id, :integer

  end
end
