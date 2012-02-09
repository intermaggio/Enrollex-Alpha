class RemoveDescFromCourses < ActiveRecord::Migration
  def up
    remove_column :courses, :desc
      end

  def down
    add_column :courses, :desc, :text
  end
end
