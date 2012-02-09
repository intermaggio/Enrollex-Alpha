class RemoveChargeIdFromCharges < ActiveRecord::Migration
  def up
    remove_column :charges, :charge_id
      end

  def down
    add_column :charges, :charge_id, :string
  end
end
