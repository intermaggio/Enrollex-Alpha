class AddSliderToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :slider, :boolean, default: false

  end
end
