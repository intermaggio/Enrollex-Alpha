class AddCreatedAtToInstructorsCourses < ActiveRecord::Migration
  def change
    add_column :instructors_courses, :created_at, :datetime

  end
end
