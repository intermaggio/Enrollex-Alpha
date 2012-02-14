class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :course_admin_path

  before_filter :auth_from_cookie

  def auth_from_cookie
    auto_login(User.find(cookies[:cm_user_id])) if cookies[:cm_user_id].present?
  end

  def course_admin_path course
    "/admin/courses/#{course.id}/#{URI::escape course.lowname}"
  end

  expose(:organization) { Organization.find_by_subdomain request.subdomain }
  expose(:course) { Course.where(id: params[:id]).first }
  expose(:courses) { organization.courses.featured.reorder(:created_at) }
end
