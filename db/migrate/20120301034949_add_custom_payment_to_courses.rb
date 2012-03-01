class AddCustomPaymentToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :reg_description, :text

    add_column :courses, :reg_link, :string

  end
end
