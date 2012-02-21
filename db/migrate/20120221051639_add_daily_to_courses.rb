class AddDailyToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :daily, :boolean

  end
end
