class AddLownameToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :lowname, :string

  end
end
