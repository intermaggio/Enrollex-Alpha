class AddFeaturedToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :featured, :boolean

  end
end
