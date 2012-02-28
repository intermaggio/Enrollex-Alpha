class RemoveStrPriceFromCourses < ActiveRecord::Migration
  def up
    remove_column :courses, :price
      end

  def down
    add_column :courses, :price, :string
  end
end
