class AdminController < InheritedResources::Base

  before_filter :authorize

  def update_org
    organization.update_attributes params[:organization]
    redirect_to request.referer, notice: :success
  end

  def authorize
    redirect_to '/' unless logged_in? && current_user.admin_organizations.include?(organization)
  end

  def manage_course
    @json = course.days.reorder(:date).map {|d| { day: d.date, start_time: d.start_time, end_time: d.end_time } }.to_json
  end

end
