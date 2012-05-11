class AddInstructorShiftExpiryHoursToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :instructorShiftExpiryHours, :integer, default: 24

  end
end
