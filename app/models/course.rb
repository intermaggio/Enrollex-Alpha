class Course < ActiveRecord::Base
  belongs_to :organization

  validates_presence_of :name
  validates_uniqueness_of :name, scope: :organization_id

  mount_uploader :image, CourseImage

  scope :featured, where(featured: true)
end
