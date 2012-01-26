class SiteController < ApplicationController

  def index
    render 'organization' if organization
  end

end
