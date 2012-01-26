class ApplicationController < ActionController::Base
  protect_from_forgery

  expose(:organization) { Organization.find_by_subdomain request.subdomain }
end
