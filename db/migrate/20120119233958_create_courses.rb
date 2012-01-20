class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :name
      t.text :desc
      t.integer :price

      t.timestamps
    end
  end
end
