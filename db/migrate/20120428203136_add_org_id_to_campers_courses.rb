class AddOrgIdToCampersCourses < ActiveRecord::Migration
  def change
    add_column :campers_courses, :org_id, :integer

  end
end
