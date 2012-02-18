class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :course_admin_path, :gmaps

  before_filter :auth_from_cookie

  def auth_from_cookie
    if cookies[:cm_user_id].present?
      user = User.find cookies[:cm_user_id]
      auto_login(user) if cookies[:cm_hash].to_i == user.salt.to_i(36)
    end
  end

  def gmaps address
    "http://maps.google.com/maps/api/staticmap?center=#{address}&zoom=15&format=png&maptype=roadmap&mobile=true&markers=|color:red|#{address}&size=300x300&key=&sensor=false"
  end

  expose(:organization) { Organization.find_by_subdomain request.subdomain }
  expose(:course) { Course.where(id: params[:id]).first }
  expose(:courses) { organization.courses.reorder(:created_at) }
  expose(:featured_courses) { organization.courses.featured.reorder(:created_at) }
  expose(:instructors) { organization.instructors.reorder('created_at DESC') }
end
