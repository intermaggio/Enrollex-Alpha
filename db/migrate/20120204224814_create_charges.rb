class CreateCharges < ActiveRecord::Migration
  def change
    create_table :charges do |t|
      t.string :charge_id

      t.timestamps
    end
  end
end
