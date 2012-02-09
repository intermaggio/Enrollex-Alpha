class AddOrganizationIdToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :organization_id, :integer

  end
end
