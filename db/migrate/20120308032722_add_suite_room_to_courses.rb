class AddSuiteRoomToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :suite, :string

    add_column :courses, :room, :string

  end
end
