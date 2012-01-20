class UsersMailer < ActionMailer::Base
  default from: 'turfbot@myturf.com', content_type: 'text/html'

  def reset_password to
    mail to: to, subject: 'blah'
  end

end
