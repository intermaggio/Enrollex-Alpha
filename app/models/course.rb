class Course < ActiveRecord::Base
  def full_address
    "#{self.address} #{self.city} #{self.state} #{self.zip}"
  end

  serialize :which_days, Hash

  belongs_to :organization

  validates_presence_of :name
  validates_presence_of :price

  mount_uploader :image, CourseImage

  scope :featured, where(featured: true)
  scope :published, where(published: true)
  scope :mirai, lambda {
    { conditions: ['start_date >= ?', Time.now.to_date] }
  }
  scope :search, lambda { |query|
    { conditions: ['name||description||city||state||location_name||id||date_string ilike ?', '%' + query + '%'] }
  }

  has_many :days
  has_and_belongs_to_many :campers
  has_and_belongs_to_many :instructors, class_name: 'User', join_table: 'instructors_courses'

  before_save do
    self.lowname = self.name.downcase.gsub(' ', '_').gsub(/\W/, '')
    self.published_at = Time.now.to_date if self.published_at.nil? && self.published
    days = self.days.reorder(:date)
    self.start_date = days.first.date if days.first
  end
end
