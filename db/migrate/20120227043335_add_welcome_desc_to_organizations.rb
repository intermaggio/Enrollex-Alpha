class AddWelcomeDescToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :welcome_message, :text

  end
end
