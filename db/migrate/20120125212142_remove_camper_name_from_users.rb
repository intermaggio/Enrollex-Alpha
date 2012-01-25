class RemoveCamperNameFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :camper_name
      end

  def down
    add_column :users, :camper_name, :string
  end
end
