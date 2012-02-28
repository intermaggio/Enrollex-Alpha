class AddStripeToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :stripe_secret, :string

    add_column :organizations, :stripe_publishable, :string

  end
end
