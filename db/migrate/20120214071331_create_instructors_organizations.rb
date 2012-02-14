class CreateInstructorsOrganizations < ActiveRecord::Migration
  def change
    create_table :instructors_organizations do |t|
      t.integer :user_id
      t.integer :organization_id
    end
  end
end
