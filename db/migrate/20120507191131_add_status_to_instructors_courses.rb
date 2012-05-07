class AddStatusToInstructorsCourses < ActiveRecord::Migration
  def change
    add_column :instructors_courses, :status, :string, default: 'pending'

  end
end
