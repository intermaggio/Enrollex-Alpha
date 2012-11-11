class AdminController < InheritedResources::Base
  before_filter :authorize

  def authorize
    raise NotAuthorized unless current_user && current_user.admin.organization.include?(organization)
  end


