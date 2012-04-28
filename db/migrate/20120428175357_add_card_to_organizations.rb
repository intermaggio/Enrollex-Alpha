class AddCardToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :card, :string

  end
end
