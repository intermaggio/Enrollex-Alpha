class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :course_admin_path

  before_filter :auth_from_cookie

  def auth_from_cookie
    if cookies[:cm_user_id]
      user = User.find cookies[:cm_user_id]
      auto_login(user) if cookies[:cm_hash] == user.salt.to_i(36)
    end
  end

  def course_admin_path course
    "/admin/courses/#{course.id}/#{URI::escape course.lowname}"
  end

  expose(:organization) { Organization.find_by_subdomain request.subdomain }
  expose(:course) { Course.where(id: params[:id]).first }
  expose(:courses) { organization.courses.reorder(:created_at) }
  expose(:featured_courses) { organization.courses.featured.reorder(:created_at) }
  expose(:instructors) { organization.instructors.reorder('created_at DESC') }
end
