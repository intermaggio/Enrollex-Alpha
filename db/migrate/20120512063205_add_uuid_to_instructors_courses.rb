class AddUuidToInstructorsCourses < ActiveRecord::Migration
  def change
    add_column :instructors_courses, :uuid, :string

  end
end
