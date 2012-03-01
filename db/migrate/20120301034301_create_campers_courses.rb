class CreateCampersCourses < ActiveRecord::Migration
  def change
    create_table :campers_courses do |t|
      t.integer :camper_id
      t.integer :course_id
    end
  end
end
