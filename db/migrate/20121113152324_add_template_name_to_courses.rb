class AddTemplateNameToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :template_name, :string

  end
end
