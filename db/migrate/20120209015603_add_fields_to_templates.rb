class AddFieldsToTemplates < ActiveRecord::Migration
  def change
    add_column :templates, :name, :string

    add_column :templates, :description, :text

    add_column :templates, :price, :integer

    add_column :templates, :image, :string

  end
end
