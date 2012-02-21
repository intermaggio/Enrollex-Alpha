class AddTimesToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :time_exceptions, :text

    add_column :courses, :time_string, :string

  end
end
