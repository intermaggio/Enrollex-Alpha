class UsersMailer < ActionMailer::Base
  default from: 'robot@enrollex.org', content_type: 'text/html'

  def reset_password to
    mail to: to, subject: 'blah'
  end

  def instructorNotificationEmail(instructor, course, uuid)
    @instructor = instructor
    @course = course
    @uuid = uuid
    mail to: instructor.email, subject: 'New Course Assignment Pending'
  end

end
