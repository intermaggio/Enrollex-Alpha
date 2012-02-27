class AddPublishedAtToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :published_at, :date

  end
end
