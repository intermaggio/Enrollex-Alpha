class AddDeadlineToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :deadline, :date

  end
end
