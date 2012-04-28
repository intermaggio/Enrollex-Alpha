class CampersCourses < ActiveRecord::Base
  validates_uniqueness_of :course_id, scope: :user_id

  scope :within, lambda { |start_date, end_date|
    { conditions: [ 'charged_at >= ? and charged_at <= ?', start_date, end_date ] }
  }
end
