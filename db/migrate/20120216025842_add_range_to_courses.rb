class AddRangeToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :range_type, :string

  end
end
