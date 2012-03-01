class AddMaxEnrollmentsToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :max_campers, :integer

  end
end
