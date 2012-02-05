class AddCidToDays < ActiveRecord::Migration
  def change
    add_column :days, :scheduled_course_id, :integer

  end
end
