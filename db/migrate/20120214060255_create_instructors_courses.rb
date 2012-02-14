class CreateInstructorsCourses < ActiveRecord::Migration
  def change
    create_table :instructors_courses do |t|
      t.integer :course_id
      t.integer :user_id
    end
  end
end
