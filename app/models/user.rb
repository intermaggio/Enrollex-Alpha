class User < ActiveRecord::Base
  authenticates_with_sorcery!

  has_many :campers
  has_and_belongs_to_many :admin_organizations, class_name: 'Organization', join_table: 'organizations_admins'
  has_and_belongs_to_many :organizations

  validates_confirmation_of :password
  validates_presence_of :email
  validates_uniqueness_of :email
end
