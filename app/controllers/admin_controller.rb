class AdminController < InheritedResources::Base
  before_filter :authorize

  def authorize
    raise NotAuthorized unless current_user && current_user.admin_organizations.include?(organization)
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

  def update_card
    Stripe.api_key =
      if Rails.env == 'production'
        'XfaZC4N7Fprblt21L8o91wFmsr0iGnYR'
      else
        's6f5O2kuPgMtxRDwA2cZ4RmPhCd8a4rX'
      end
    @customer = Stripe::Customer.create(
      description: organization.name,
      card: params[:stripeToken]
    )
    organization.update_attribute(:card, @customer.id)
    respond_to :js
  end

  def refund
    Stripe.api_key = organization.stripe_secret
    Stripe::Charge.retrieve(params[:stripe]).refund
  end

  def destroy
    course = Course.find(params[:id])
    @id = course.id
    course.destroy
    respond_to :js
  end

  def update
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

  def update_org
    organization.update_attributes params[:organization]
    if params[:organization][:timezone]
      timezone = (ActiveSupport::TimeZone.find_tzinfo(organization.timezone).current_period.utc_offset / 3600).to_s
      organization.timezone =
        if timezone[0] == '-'
          if timezone.length < 3
            timezone[0] + '0' + timezone[1] + ':00'
          else
            timezone + ':00'
          end
        else
          if timezone.length < 2
            '+0' + timezone + ':00'
          else
            '+' + timezone + ':00'
          end
        end
      organization.save
    end
    @org = organization if params[:organization][:banner].present?
    redirect_to request.referer, notice: :success
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

  def schedule_course
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
    course.days.each { |d| days.push d }
    which_days = find_days course
    course.which_days = which_days
    course.daily = daily course
    course.save if params[:finalize]
    #days = {'sunday' => 0, 'monday' => 1, 'tuesday' => 2, 'wednesday' => 3, 'thursday' => 4, 'friday' => 5, 'saturday' => 6}
    total = which_days.reduce(0) { |sum, day| sum += day.last }
    rdays = which_days.map { |day| day.last > total / 4 && day.first.capitalize || nil }.compact
    #exception_days = course.which_days.map { |day| day.last <= total / 4 && day.first || nil }.compact
    #course.days.each do |day|
      #day.date.wday ==
    #end
    exceptions = []
    days.uniq!.sort_by!(&:date)
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

  def manage_course
    @json = course.days.reorder(:date).map {|d| { day: (d.date.to_time.to_i.to_s + '000').to_i, start_time: (d.start_time.to_i.to_s + '000').to_i, end_time: (d.end_time.to_i.to_s + '000').to_i } }.to_json
  end

  def org
    Stripe.api_key = organization.stripe_secret if !organization.card
    render 'organization'
  end

end
