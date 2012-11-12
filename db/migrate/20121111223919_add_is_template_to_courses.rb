class AddIsTemplateToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :is_template, :boolean, :default => false

  end
end
