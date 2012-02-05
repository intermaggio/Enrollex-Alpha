class ScheduledCourse < ActiveRecord::Base
  belongs_to :course
  has_many :days
  has_many :charges
end
