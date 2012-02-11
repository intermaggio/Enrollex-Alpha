class AddSignupOptionsToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :signup_options, :string

  end
end
