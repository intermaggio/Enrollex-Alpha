class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :course_admin_path, :gmaps, :age
  rescue_from ActiveRecord::RecordNotFound, with: :render_404
  rescue_from NotAuthorized, with: :not_authorized
  rescue_from AbstractController::ActionNotFound, with: :render_404

  before_filter :auth_from_cookie

  def not_authorized
    respond_to do |format|
      format.html { render 'site/not_authorized' }
      format.js { render json: { piss_off: true } }
    end
  end

  def render_404
    render 'site/404'
  end

  def render_optional_error_file code
    if code == :not_found
      render 'site/404'
    else
      super
    end
  end

  def auth_from_cookie
    if session[:cm_user_id].present? && !cookies[:cm_user_id]
      cookies[:cm_user_id] = session[:cm_user_id]
      cookies[:cm_hash] = session[:cm_hash]
    end
    if cookies[:cm_user_id].present?
      begin
        user = User.find cookies[:cm_user_id]
        auto_login(user) if cookies[:cm_hash].to_i == user.salt.to_i(36)
      rescue
      end
    end
  end

  def gmaps address
    "<iframe width='594' height='300' frameborder='0' scrolling='no' marginheight='0' marginwidth='0' src='http://maps.google.com/maps?daddr=#{address}&amp;output=embed'></iframe>"
  end

  def age(dob)
    now = Time.now.utc.to_date
    now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
  end

  expose(:organization) { Organization.find_by_subdomain request.subdomain }
  expose(:course) { Course.find params[:id] }
  expose(:courses) { organization.courses.reorder(:created_at) }
  expose(:featured_courses) { organization.courses.featured.published.mirai.reorder(:created_at) }
  expose(:instructors) { organization.instructors.reorder('created_at DESC') }
end
