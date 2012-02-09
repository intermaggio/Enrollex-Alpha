class AddCourseIdToCharge < ActiveRecord::Migration
  def change
    add_column :charges, :course_id, :integer

  end
end
