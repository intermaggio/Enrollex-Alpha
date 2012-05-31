class AddOffsetToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :default_start_offset, :string

    add_column :courses, :default_end_offset, :string

  end
end
