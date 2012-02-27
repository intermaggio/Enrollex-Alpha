class RemoveTimeStringFromCourses < ActiveRecord::Migration
  def up
    remove_column :courses, :time_string
      end

  def down
    add_column :courses, :time_string, :string
  end
end
