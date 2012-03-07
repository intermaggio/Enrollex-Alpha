class AdminController < InheritedResources::Base
  before_filter :authorize

  def authorize
    raise NotAuthorized unless current_user && current_user.admin_organizations.include?(organization)
  end

  def refund
    Stripe.api_key = organization.stripe_secret
    Stripe::Charge.retrieve(params[:stripe]).refund
  end

  def unenroll
    user = User.find params[:user_id]
    stripe_id = CampersCourses.where(user_id: user.id, course_id: course.id).first.stripe_id
    user.courses.delete course
    Pony.mail(
      to: course.organization.admins.first.email,
      from: 'robot@enrollex.org',
      subject: 'Unenrollment',
      body: "#{user.name} has unenrolled from #{course.name}, saying:<br/><br/>\"#{params[:message]}\"<br/><br/>If you'd like to grant them a refund, visit the following link:<br/>http://#{organization.subname}.enrollex.org/courses/#{course.id}/#{course.lowname}/refund?stripe=#{stripe_id}&id=#{user.parent && user.parent.id || user.id}",
      headers: { 'Content-Type' => 'text/html' },
      via: :smtp,
      via_options: {
        address: 'smtp.gmail.com',
        port: '587',
        enable_starttls_auto: true,
        user_name: 'robot@enrollex.org',
        password: 'b0wserFire',
        authentication: :plain,
        domain: 'enrollex.org'
      }
    )
    respond_to :js
  end

  def destroy
    course = Course.find(params[:id])
    @id = course.id
    course.destroy
    respond_to :js
  end

  def update_org
    organization.update_attributes params[:organization]
    @org = organization if params[:organization][:banner].present?
    redirect_to request.referer, notice: :success
  end

  def manage_course
    @json = course.days.reorder(:date).map {|d| { day: (d.date.to_time.to_i.to_s + '000').to_i, start_time: (d.start_time.to_i.to_s + '000').to_i, end_time: (d.end_time.to_i.to_s + '000').to_i } }.to_json
  end

end
