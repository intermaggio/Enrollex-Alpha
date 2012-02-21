class AddDayHashToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :which_days, :text

  end
end
