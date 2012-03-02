class SiteController < ApplicationController

  def search
    courses = organization.courses
    courses = courses.mirai if params[:mirai] == 'true'
    courses = courses.search(params[:q]).reorder(:created_at)
    courses = courses.published if !current_user || current_user && !current_user.admin_organizations.include?(organization)
    @html = render_to_string courses
    respond_to :js
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

  def catalog
  end

end
