class AddPublishedToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :published, :boolean

  end
end
