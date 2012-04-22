class CoursesController < InheritedResources::Base

  def show
    render 'unpublished' unless course.published || organization.admins.include?(current_user)
  end

  def unenroll
    user = User.find params[:user_id]
    if current_user == user || current_user.campers.include?(user)
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
  end

  def download
    kit = PDFKit.new(render_to_string('courses/roster', layout: false, locals: { download: true }), page_size: 'Letter')
    kit.stylesheets << "#{Rails.root}/app/assets/stylesheets/bootstrap.css"
    pdf = kit.to_pdf
    file = kit.to_file("/tmp/#{course.name}.pdf")
    respond_to do |format|
      format.html { send_file "/tmp/#{course.name}.pdf", type: 'application/pdf', filename: "#{course.name}.pdf" }
    end
  end

  def register
    @campers = []
    if params[:campers]
      params[:campers].each do |id|
        @campers.push User.find(id)
      end
    else
      @campers.push current_user
    end
    redirect_to "/courses/#{course.id}/#{course.lowname}" if @campers == [] || @campers.index(false)
  end

  def update_times
    course.date_string = params[:date_string]
    course.save!
    render json: { success: true }
  end

  def remove_camper
    user = User.find(params[:id])
    if current_user.campers.include?(user)
      user.destroy
      render json: { success: true }
    else
      render json: { success: false }
    end
  end

  def template
    course.price = course.price / 100
    render json: course.to_json
  end

  def enroll
    params[:campers].each do |camper|
      user = User.find camper
      course.campers << user if current_user.campers.include?(user)
    end
    render nothing: true
  end

  def charge
    params[:campers].each do |camper|
      course.campers << User.find(camper)
    end
    Stripe.api_key = organization.stripe_secret
    cut = (params[:amount].to_f * 0.03).to_i
    amount = params[:amount].to_i - cut
    stripe = Stripe::Charge.create(
      amount: amount,
      currency: 'usd',
      card: params[:stripeToken],
      description: current_user.email + ' :: ' + course.lowname
    )
    Stripe.api_key =
      if Rails.env == 'production'
        'XfaZC4N7Fprblt21L8o91wFmsr0iGnYR'
      else
        's6f5O2kuPgMtxRDwA2cZ4RmPhCd8a4rX'
      end
    stripe = Stripe::Charge.create(
      amount: cut,
      currency: 'usd',
      card: params[:stripeToken],
      description: current_user.email + ' :: ' + course.lowname
    )
    params[:campers].each do |camper|
      CampersCourses.where(user_id: camper, course_id: course.id).first.update_attribute(:stripe_id, stripe.id)
    end
    Pony.mail(
      to: current_user.email,
      from: 'robot@enrollex.org',
      subject: 'Enrollex Receipt',
      body: "Course: #{course.name}<br/>Course ID: #{course.id}<br/><br/>Invoice ID: #{stripe.id}<br/>Invoice Date: #{Time.now.strftime('%B %d, %Y')}<br/>Invoice Amount: $#{params[:amount].to_i / 100}<br/><br/>Thanks for your enrollment!",
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
  end

end
