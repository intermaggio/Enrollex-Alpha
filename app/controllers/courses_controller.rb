class CoursesController < InheritedResources::Base

  expose(:course) { Course.where(lowname: params[:lowname]).first }

  def create
    @course = Course.new(params[:course])
    if @course.save
      organization.courses << @course
      redirect_to '/admin/courses'
    else
      render 'admin/courses'
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
