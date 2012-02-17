class Day < ActiveRecord::Base
  belongs_to :course
  validates_uniqueness_of :date, scope: :course_id
end
