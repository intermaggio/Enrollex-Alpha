class RemoveSuiteRoomFromCourses < ActiveRecord::Migration
  def up
    remove_column :courses, :suite
        remove_column :courses, :room
      end

  def down
    add_column :courses, :room, :integer
    add_column :courses, :suite, :integer
  end
end
