class AddShowMapToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :show_map, :boolean, default: true
  end
end
