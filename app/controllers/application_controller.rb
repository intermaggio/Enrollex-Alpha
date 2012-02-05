class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :login

  def login
    auto_login(User.find(cookies[:cm_user_id])) if cookies[:cm_user_id]
  end

  expose(:organization) { Organization.find_by_subdomain request.subdomain }
  expose(:course) { Course.where(lowname: params[:lowname]).first }
end
