class AddEmailsToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :email_subject, :string

    add_column :organizations, :email_message, :text

  end
end
