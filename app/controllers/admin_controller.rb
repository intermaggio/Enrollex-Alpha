class AdminController < InheritedResources::Base

  before_filter :authorize

  def courses
  end

  def authorize
    redirect_to '/' unless logged_in? && current_user.admin_organizations.include?(organization)
  end

end
