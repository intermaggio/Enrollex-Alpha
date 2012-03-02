class AddGenderToCampers < ActiveRecord::Migration
  def change
    add_column :campers, :gender, :string

  end
end
