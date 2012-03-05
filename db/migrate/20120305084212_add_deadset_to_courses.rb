class AddDeadsetToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :deadline_set, :boolean, default: false

  end
end
