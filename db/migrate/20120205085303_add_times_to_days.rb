class AddTimesToDays < ActiveRecord::Migration
  def change
    add_column :days, :start_time, :time

    add_column :days, :end_time, :time

    add_column :days, :date, :date

  end
end
