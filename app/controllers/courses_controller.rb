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

end
