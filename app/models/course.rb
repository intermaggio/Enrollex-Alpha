class Course < ActiveRecord::Base
  belongs_to :organization
  has_many :scheduled_courses

  validates_presence_of :name
  validates_uniqueness_of :name, scope: :organization_id

  mount_uploader :image, CourseImage

  scope :featured, where(featured: true)

  before_save do
    self.lowname = self.name.downcase.gsub(' ', '_')
  end
end
