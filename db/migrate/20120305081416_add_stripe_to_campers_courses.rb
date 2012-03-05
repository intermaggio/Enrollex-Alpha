class AddStripeToCampersCourses < ActiveRecord::Migration
  def change
    add_column :campers_courses, :stripe_id, :string
  end
end
