class SiteController < ApplicationController

  def callback
    session[:courses] = params[:courses]
    creds = env['omniauth.auth'].credentials
    creds['access_token'] = creds.token
    creds.delete(:token)
    current_user.update_attribute(:ghash, creds)
    redirect_to '/site/gcal_import'
  end

  def gcal_import
    courses = session[:courses].map { |c| Course.find c }
    gclient = Google::APIClient.new
    gclient.authorization.client_id = GKEY
    gclient.authorization.client_secret = GSECRET
    gclient.authorization.update_token!(current_user.ghash)
    gcal = gclient.discovered_api('calendar', 'v3')
    if verified
      courses.each do |course|
        course.days.each do |day|
          event = {
            start: { dateTime: day.start_time.change(day: day.date.day, month: day.date.month, year: day.date.year) },
            end: { dateTime: day.end_time.change(day: day.date.day, month: day.date.month, year: day.date.year) },
          }
          rsp = gclient.execute(
            api_method: gcal.events.insert,
            parameters: { 'calendarId' => 'c@chrisbolton.me' },
            body: JSON.dump(event),
            headers: { 'Content-Type' => 'application/json' }
          )
        end
      end
      render json: { success: true }
    else
      render json: { success: false }
    end
  end

  def search
    @html, page = fetch_courses(params[:uid], params[:mirai], params[:q])
    if page == :enrollments
      respond_to do |format|
        format.js { render 'search_enrollments' }
      end
    end
  end

  def fetch_courses(uid, mirai, query)
    begin
      user = User.find uid
      html = {}
      courses = user.courses.where(organization_id: organization.id)
      if courses.first
        courses = courses.mirai if mirai == 'true'
        courses = courses.search(query).reorder(:created_at)
        html[user.id] = render_to_string courses
      end
      user.campers.each do |camper|
        courses = camper.courses.where(organization_id: organization.id)
        if courses.first
          courses = courses.mirai if mirai == 'true'
          courses = courses.search(query).reorder(:created_at)
          html[camper.id] = render_to_string courses
        end
      end
      return html, :enrollments
    rescue
      courses = organization.courses
      courses = courses.mirai if mirai == 'true'
      courses = courses.search(query).reorder(:created_at)
      courses = courses.published if !current_user || current_user && !current_user.admin_organizations.include?(organization)
      html = render_to_string courses
      return html, :all
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
