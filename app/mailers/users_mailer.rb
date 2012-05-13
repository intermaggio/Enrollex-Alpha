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

  def monthlyInvoice(email, amount, organization)
    @amount = amount
    @organization = organization
    mail from: 'robot@enrollex.org', to: email, subject: 'Your Monthly Enrollex Invoice'
  end

end
