class AddDefaultValuesToCourses < ActiveRecord::Migration
  def change
    change_column :courses, :date_string, :string, default: ''
  end
end
