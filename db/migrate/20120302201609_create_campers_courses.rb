class CreateCampersCourses < ActiveRecord::Migration
  def change
    create_table :campers_courses do |t|
      t.integer :user_id
      t.integer :course_id

      t.timestamps
    end
  end
end
