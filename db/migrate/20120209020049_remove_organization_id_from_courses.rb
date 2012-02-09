class RemoveOrganizationIdFromCourses < ActiveRecord::Migration
  def up
    remove_column :courses, :organization_id
      end

  def down
    add_column :courses, :organization_id, :integer
  end
end
