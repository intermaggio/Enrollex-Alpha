class InstructorsCourses < ActiveRecord::Base
  validates_uniqueness_of :course_id, scope: :user_id
end
