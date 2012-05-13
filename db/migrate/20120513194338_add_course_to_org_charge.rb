class AddCourseToOrgCharge < ActiveRecord::Migration
  def change
    add_column :org_charges, :course_id, :integer

  end
end
