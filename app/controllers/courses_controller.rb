class CoursesController < InheritedResources::Base

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
    JSON.parse(params[:daytimes]).each do |daytime|
      day = course.days.new
      day.date = daytime['day']
      day.start_time = daytime['start_time']
      day.end_time = daytime['end_time']
    end
    if course.save
      render json: { success: true, tiems: course.days.reorder(:date) }
    else
      render json: { success: false }
    end
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
