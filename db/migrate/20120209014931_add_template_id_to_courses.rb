class AddTemplateIdToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :template_id, :integer

  end
end
