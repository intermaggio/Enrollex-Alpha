class AddCidToScheduledCourse < ActiveRecord::Migration
  def change
    add_column :scheduled_courses, :course_id, :integer

  end
end
