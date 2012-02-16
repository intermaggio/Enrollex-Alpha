class AddAddressToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :address, :string

    add_column :courses, :city, :string

    add_column :courses, :state, :string

    add_column :courses, :zip, :string

  end
end
