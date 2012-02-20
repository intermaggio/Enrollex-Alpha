class CoursesController < InheritedResources::Base

  def update
    course = Course.find params[:id]
    course.update_attributes params[:course]
    respond_to :js
  end

  def create
    @course = Course.new params[:course]
    if params[:instructors]
      params[:instructors].each do |hash|
        @course.instructors << User.find(hash.first) if hash.last == '1'
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
    render json: course.to_json
  end

  def schedule
    course = Course.find params[:id]
    days = []
    JSON.parse(params[:daytimes]).each do |daytime|
      course.days.where(date: daytime['day'].to_date).destroy_all
      day = course.days.new
      day.date = daytime['day']
      day.start_time = daytime['start_time']
      day.end_time = daytime['end_time']
      days.push day
    end
    course.save if params[:finalize]
    render json: { success: true, tiems: days.map {|d| { date: (d.date.to_time.to_i.to_s + '000').to_i, start: (d.start_time.to_i.to_s + '000').to_i, end: (d.end_time.to_i.to_s + '000').to_i } } }
  end

  def charge
    Stripe::Charge.create(
      amount: params[:amount],
      currency: 'usd',
      card: params[:stripeToken],
      description: current_user.email + ' :: ' + course.lowname
    )
  end

end
