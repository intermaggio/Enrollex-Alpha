class AddInfoToCampers < ActiveRecord::Migration
  def change
    add_column :campers, :health_info, :text

    add_column :campers, :birthday, :date

    add_column :campers, :first_name, :string

    add_column :campers, :last_name, :string
    add_column :campers, :street, :string
    add_column :campers, :city, :string
    add_column :campers, :state, :string
    add_column :campers, :zip, :string

  end
end
