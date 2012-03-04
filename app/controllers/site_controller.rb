class SiteController < ApplicationController

  def search
    begin
      user = User.find params[:uid]
      @html = {}
      courses = user.courses.where(organization_id: organization.id)
      if courses.first
        courses = courses.mirai if params[:mirai] == 'true'
        courses = courses.search(params[:q]).reorder(:created_at)
        @html[user.id] = render_to_string courses
      end
      user.campers.each do |camper|
        courses = camper.courses.where(organization_id: organization.id)
        if courses.first
          courses = courses.mirai if params[:mirai] == 'true'
          courses = courses.search(params[:q]).reorder(:created_at)
          @html[camper.id] = render_to_string courses
        end
      end
      respond_to do |format|
        format.js { render 'search_enrollments' }
      end
    rescue
      courses = organization.courses
      courses = courses.mirai if params[:mirai] == 'true'
      courses = courses.search(params[:q]).reorder(:created_at)
      courses = courses.published if !current_user || current_user && !current_user.admin_organizations.include?(organization)
      @html = render_to_string courses
      respond_to :js
    end
  end

  def index
    if request.subdomain.present?
      if organization
        render 'organization'
      else
        render '/site/404'
      end
    end
  end

  def profile
    redirect_to '/' if !current_user
  end

end
