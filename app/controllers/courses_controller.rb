class CoursesController < InheritedResources::Base

  def register
    @campers = []
    params[:campers].each do |id|
      @campers.push Camper.find(id)
    end
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
      course.save!
    end
    respond_to :js
  end

  def create
    @course = Course.new params[:course]
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

  def charge
    params[:campers].each do |camper|
      course.campers << Camper.find(camper.last[:id])
    end
    binding.pry
    Stripe.api_key = organization.stripe_secret
    Stripe::Charge.create(
      amount: params[:amount],
      currency: 'usd',
      card: params[:stripeToken],
      description: current_user.email + ' :: ' + course.lowname
    )
  end

end
