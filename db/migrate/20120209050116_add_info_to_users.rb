class AddInfoToUsers < ActiveRecord::Migration
  def change
    add_column :users, :birthday, :date

    add_column :users, :phone, :string

    add_column :users, :street, :string

    add_column :users, :city, :string

    add_column :users, :state, :string

    add_column :users, :zip, :string

  end
end
