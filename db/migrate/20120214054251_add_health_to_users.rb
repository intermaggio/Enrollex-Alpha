class AddHealthToUsers < ActiveRecord::Migration
  def change
    add_column :users, :health_info, :text

  end
end
