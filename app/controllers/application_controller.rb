class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :auth_from_cookie

  def auth_from_cookie
    auto_login(User.find(cookies[:cm_user_id])) if cookies[:cm_user_id].present?
  end

  expose(:organization) { Organization.find_by_subdomain request.subdomain }
  expose(:course) { Course.where(lowname: params[:lowname]).first }
  expose(:courses) { organization.courses.featured.reorder(:created_at) }
end
