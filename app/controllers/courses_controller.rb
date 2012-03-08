class CoursesController < InheritedResources::Base

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

  def daily course
    falsey = course.days.each_with_index.map { |day,i|
      if day == course.days.last && day.date == course.days[i - 1].date + 1.day
        true
      elsif day != course.days.last && day.date == course.days[i + 1].date - 1.day
        true
      else
        false
      end
    }.index false
    if falsey then false else true end
  end

  def find_days course
    days = {'0' => 'sunday', '1' => 'monday', '2' => 'tuesday', '3' => 'wednesday', '4' => 'thursday', '5' => 'friday', '6' => 'saturday'}
    results = {}
    course.days.each do |obj|
      day = obj.date.wday
      results[days[day.to_s]] = 0 unless results[days[day.to_s]]
      results[days[day.to_s]] += 1
    end
    results
  end

  def update_times
    course.date_string = params[:date_string]
    course.save!
    render json: { success: true }
  end

  def update
    course = Course.find params[:id]
    course.update_attributes params[:course]
    if params[:course][:deadline].present?
      deadline = params[:course][:deadline].split(/\W/)
      course.deadline = deadline[1] + '/' + deadline[0] + '/' + deadline[2]
      course.deadline_set = true
    else
      course.deadline_set = false
    end
    if params[:price].index('.')
      course.price = params[:price].gsub('.', '')
    else
      course.price = params[:price] + '00'
    end
    course.instructors = []
    if params[:instructor]
      params[:instructor].each do |hash|
        course.instructors << User.find(hash.last)
      end
    end
    course.save!
    redirect_to "/admin/courses/#{course.id}", notice: :success
  end

  def create
    @course = Course.new params[:course]
    if params[:course][:deadline].present?
      deadline = params[:course][:deadline].split(/\W/)
      @course.deadline = Date.parse deadline[1] + '-' + deadline[0] + '-' + deadline[2]
      @course.deadline_set = true
    end
    if params[:price].index('.')
      @course.price = params[:price].gsub('.', '').to_i
    else
      @course.price = (params[:price] + '00').to_i
    end
    if params[:instructor]
      params[:instructor].each do |hash|
        @course.instructors << User.find(hash.last)
      end
    end
    if @course.save
      organization.courses << @course
      redirect_to "/admin/courses/#{@course.id}/schedule"
    else
      render 'admin/courses'
    end
  end

  def template
    course.price = course.price / 100
    render json: course.to_json
  end

  def schedule
    course = Course.find params[:id]
    if !params[:finalize] && params[:start][:hour] != 'NaN'
      course.default_start = params[:start][:hour] + ':' + params[:start][:min]
      course.default_end = params[:end][:hour] + ':' + params[:end][:min]
    end
    course.days.destroy_all
    days = []
    JSON.parse(params[:daytimes]).each do |daytime|
      day = course.days.new
      day.date = daytime['day']
      day.start_time = daytime['start_time']
      day.end_time = daytime['end_time']
      days.push day
    end
    course.which_days = find_days course
    course.daily = daily course
    course.save!
    #days = {'sunday' => 0, 'monday' => 1, 'tuesday' => 2, 'wednesday' => 3, 'thursday' => 4, 'friday' => 5, 'saturday' => 6}
    total = course.which_days.reduce(0) { |sum, day| sum += day.last }
    rdays = course.which_days.map { |day| day.last > total / 4 && day.first.capitalize || nil }.compact
    #exception_days = course.which_days.map { |day| day.last <= total / 4 && day.first || nil }.compact
    #course.days.each do |day|
      #day.date.wday ==
    #end
    exceptions = []
    days = course.days.reorder(:date)
    render json: {
      rdays: rdays,
      exceptions: exceptions,
      start_date: (days.first.date.to_time.to_i.to_s + '000').to_i,
      end_date: (days.last.date.to_time.to_i.to_s + '000').to_i,
      tiems: days.map { |d|
        {
          date: (d.date.to_time.to_i.to_s + '000').to_i,
          start: (d.start_time.to_i.to_s + '000').to_i,
          end: (d.end_time.to_i.to_s + '000').to_i
        }
      }
    }
  end

  def enroll
    params[:campers].each do |camper|
      course.campers << User.find(camper)
    end
    render nothing: true
  end

  def charge
    params[:campers].each do |camper|
      course.campers << User.find(camper)
    end
    Stripe.api_key = organization.stripe_secret
    stripe = Stripe::Charge.create(
      amount: params[:amount],
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
