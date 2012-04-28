class AddTimestampToCampersCourses < ActiveRecord::Migration
  def change
    add_column :campers_courses, :charged_at, :datetime

  end
end
