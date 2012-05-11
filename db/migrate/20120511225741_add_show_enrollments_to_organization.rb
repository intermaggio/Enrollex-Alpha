class AddShowEnrollmentsToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :showEnrollments, :boolean, default: true

  end
end
