class User < ActiveRecord::Base
  authenticates_with_sorcery!

  before_validation(on: :create) do
    if self.utype == 'camper'
      self.email = "camper#{self.id}@enrollex.org"
    end
  end

  after_create do
    unless self.salt
      Pony.mail(
      to: self.email,
      from: 'robot@enrollex.org',
      subject: 'Enrollex invitation',
      body: "Hey there! #{self.instructing_for.last.name} has just listed you as an instructor. To complete your registration, just visit the following link: http://#{self.instructing_for.last.subname}.enrollex.org/signup?type=email&id=#{self.id}&hash=#{self.hash.abs}. Thanks!",
      via: :smtp,
      via_options: {
        address: 'smtp.gmail.com',
        port: '587',
        enable_starttls_auto: true,
        user_name: 'robot@enrollex.org',
        password: 'b0wserFire',
        authentication: :plain,
        domain: 'enrollex.org'
      }
    )
    end
  end

  mount_uploader :image, UserImage

  has_many :campers, class_name: 'User', foreign_key: 'parent_id'
  belongs_to :parent, class_name: 'User', foreign_key: 'parent_id'
  has_and_belongs_to_many :admin_organizations, class_name: 'Organization', join_table: 'organizations_admins'
  has_and_belongs_to_many :organizations
  has_and_belongs_to_many :instructing, class_name: 'Course', join_table: 'instructors_courses'
  has_and_belongs_to_many :instructing_for, class_name: 'Organization', join_table: 'instructors_organizations'
  has_and_belongs_to_many :courses, join_table: 'campers_courses'

  validates_confirmation_of :password
  validates_presence_of :email
  validates_uniqueness_of :email

  def name
    self.first_name + ' ' + self.last_name
  end
end
