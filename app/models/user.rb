class User < ActiveRecord::Base
  authenticates_with_sorcery!

  has_many :campers
  has_and_belongs_to_many :admin_organizations, class_name: 'Organization', join_table: 'organizations_admins'
  has_and_belongs_to_many :organizations
  has_and_belongs_to_many :instructing, class_name: 'Course', join_table: 'instructors_courses'
  has_and_belongs_to_many :instructing_for, class_name: 'Organization', join_table: 'instructors_organizations'

  validates_confirmation_of :password
  validates_presence_of :email
  validates_uniqueness_of :email

  def name
    self.first_name + ' ' + self.last_name
  end
end
