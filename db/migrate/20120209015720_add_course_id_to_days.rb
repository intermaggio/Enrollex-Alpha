class AddCourseIdToDays < ActiveRecord::Migration
  def change
    add_column :days, :course_id, :integer

  end
end
