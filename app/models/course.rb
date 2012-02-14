class Course < ActiveRecord::Base
  belongs_to :organization

  validates_presence_of :name

  mount_uploader :image, CourseImage

  scope :featured, where(featured: true)

  has_many :days

  before_save do
    self.lowname = self.name.downcase.gsub(/[ .]/, '_').gsub("'", '')
  end
end
