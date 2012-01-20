class SorceryCore < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :email,            :null => false
      t.string :crypted_password, :default => nil
      t.string :salt,             :default => nil
      t.string :camper_name, null: false
      t.string :family_name, null: false
      t.string :parent_name, null: false
      t.string :phone, null: false
      t.string :address

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
