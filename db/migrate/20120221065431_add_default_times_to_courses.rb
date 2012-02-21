class AddDefaultTimesToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :default_start, :time

    add_column :courses, :default_end, :time

  end
end
