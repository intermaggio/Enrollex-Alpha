class AddStuffToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :notes, :text

    add_column :courses, :start_range, :integer

    add_column :courses, :end_range, :integer

  end
end
