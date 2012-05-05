class InstructorsController < InheritedResources::Base
  before_filter :authorize
  respond_to :js, :html

  expose(:instructor) { User.find params[:id] }

  def authorize
    raise NotAuthorized unless current_user && current_user.admin_organizations.include?(organization)
  end

  def destroy
    organization.instructors.delete(User.find(params[:id]))
  end

  def update
    User.find(params[:id]).update_attributes(params[:user])
    redirect_to '/admin/instructors'
  end

  def edit
  end

end
