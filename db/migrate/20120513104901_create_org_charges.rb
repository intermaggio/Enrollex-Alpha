class CreateOrgCharges < ActiveRecord::Migration
  def change
    create_table :org_charges do |t|
      t.string :stripe_id

      t.timestamps
    end
  end
end
