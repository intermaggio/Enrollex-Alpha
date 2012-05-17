class UsersMailer < ActionMailer::Base
  default from: 'robot@enrollex.org', content_type: 'text/html'

  def instructorNotification(instructor, course, uuid)
    @instructor = instructor
    @course = course
    @uuid = uuid
    mail to: instructor.email, subject: 'New Course Assignment Pending'
  end

  def monthlyInvoice(email, amount, organization)
    @amount = amount
    @organization = organization
    mail to: email, subject: 'Your Monthly Enrollex Invoice'
  end

  def stripeError(email, error)
    @error = error
    mail to: email, subject: 'Monthly charge failed'
  end

end
