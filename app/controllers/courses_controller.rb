class CoursesController < InheritedResources::Base

  def create
    @course = Course.new(params[:course])
    if @course.save
      organization.courses << @course
      redirect_to '/admin/courses'
    else
      render 'admin/courses'
    end
  end

  def schedule
    scheduled_course = course.scheduled_courses.new
    JSON.parse(params[:daytimes]).each do |daytime|
      day = scheduled_course.days.new
      day.date = daytime['day']
      day.start_time = daytime['start_time']
      day.end_time = daytime['end_time']
    end
    scheduled_course.save
    render json: { success: true }
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
