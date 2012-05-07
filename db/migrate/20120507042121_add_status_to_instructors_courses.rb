class AddStatusToInstructorsCourses < ActiveRecord::Migration
  def change
    add_column :instructors_courses, :accepted, :boolean, default: false

  end
end
