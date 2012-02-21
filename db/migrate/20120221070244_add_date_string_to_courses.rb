class AddDateStringToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :date_string, :string

  end
end
