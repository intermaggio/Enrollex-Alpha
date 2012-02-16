class RemovePriceFromCourses < ActiveRecord::Migration
  def up
    remove_column :courses, :price
      end

  def down
    add_column :courses, :price, :integer
  end
end
