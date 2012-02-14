class User < ActiveRecord::Base
  authenticates_with_sorcery!
  
  after_create do
    unless self.salt
      Pony.mail(
      to: self.email,
      from: 'robot@teslaprime.com',
      subject: 'CourseManage invitation',
      body: "Hey there! #{self.organizations.last} has just listed you as an instructor. <<
             To complete your registration, just visit the following link: http://#{self.organizations.last.subname}.teslaprime.com/signup?type=email&id=#{self.id}. Thanks!",
      via: :smtp,
      via_options: {
        address: 'smtp.gmail.com',
        port: '587',
        enable_starttls_auto: true,
        user_name: 'robot@teslaprime.com',
        password: 'b0wserFire',
        authentication: :plain,
        domain: 'teslaprime.com'
      }
    )
    end
  end

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
