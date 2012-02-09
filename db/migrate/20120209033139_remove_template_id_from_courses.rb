class RemoveTemplateIdFromCourses < ActiveRecord::Migration
  def up
    remove_column :courses, :template_id
      end

  def down
    add_column :courses, :template_id, :integer
  end
end
