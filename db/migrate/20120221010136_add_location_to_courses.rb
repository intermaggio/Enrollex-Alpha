class AddLocationToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :location_name, :string

  end
end
