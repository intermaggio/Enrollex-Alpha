class AddNumsToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :suite, :integer

    add_column :courses, :room, :integer

  end
end
