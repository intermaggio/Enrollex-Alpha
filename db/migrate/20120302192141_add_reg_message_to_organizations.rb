class AddRegMessageToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :registration_message, :text

  end
end
