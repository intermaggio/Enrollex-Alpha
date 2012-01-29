class AdminController < InheritedResources::Base

  before_filter :authorize

  def update_org
    organization.update_attributes params[:organization]
    redirect_to request.referer, notice: :success
  end

  def authorize
    redirect_to '/' unless logged_in? && current_user.admin_organizations.include?(organization)
  end

end
