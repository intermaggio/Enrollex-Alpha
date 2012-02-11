class RemoveNameFromCampers < ActiveRecord::Migration
  def up
    remove_column :campers, :name
      end

  def down
    add_column :campers, :name, :string
  end
end
