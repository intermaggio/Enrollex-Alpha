class SiteController < ApplicationController

  def catalog
    unless request.subdomain.present?
      redirect_to "http://#{session[:subdomain]}.#{request.domain}/catalog", flash: { cal: true }
    else
      @courses = organization.courses
      @courses = @courses.mirai if params[:m] == '1'
      @courses = @courses.search(params[:q]).reorder(:created_at) if params[:q]
      @courses = @courses.published if !current_user || current_user && !current_user.admin_organizations.include?(organization)
    end
  end

  def callback
    creds = env['omniauth.auth'].credentials
    creds['access_token'] = creds.token
    creds.delete(:token)
    current_user.update_attribute(:ghash, creds)
    redirect_to '/catalog'
  end

  def calendar_session
    gclient = Google::APIClient.new
    gclient.authorization.client_id = GKEY
    gclient.authorization.client_secret = GSECRET
    gclient.authorization.update_token!(current_user.ghash)
    gcal = gclient.discovered_api('calendar', 'v3')
    calendars = gclient.execute(api_method: gcal.calendar_list.list)
    session[:calendars] = calendars.data.items.map { |c| { id: c.id, title: c.summary } }
    render json: session[:calendars].to_json
  end

  def calendar_list
    session[:courses] = params[:courses]
    session[:subdomain] = organization.subname
    unless !current_user.ghash || current_user.ghash == {}
      gclient = Google::APIClient.new
      gclient.authorization.client_id = GKEY
      gclient.authorization.client_secret = GSECRET
      gclient.authorization.update_token!(current_user.ghash)
      gcal = gclient.discovered_api('calendar', 'v3')
      calendars = gclient.execute(api_method: gcal.calendar_list.list)
      session[:calendars] = calendars.data.items.map { |c| { id: c.id, title: c.summary } }
      if calendars.data['error']
        render json: { success: false }
      else
        render json: { success: true, calendars: session[:calendars] }
      end
    else
      render json: { success: false }
    end
  end

  def gcal_import
    courses = session[:courses].map { |c| Course.find c }
    gclient = Google::APIClient.new
    gclient.authorization.client_id = GKEY
    gclient.authorization.client_secret = GSECRET
    gclient.authorization.update_token!(current_user.ghash)
    gcal = gclient.discovered_api('calendar', 'v3')
    courses.each do |course|
      course.days.each do |day|
        event = {
          start: { dateTime: day.start_time.change(day: day.date.day, month: day.date.month, year: day.date.year) },
          end: { dateTime: day.end_time.change(day: day.date.day, month: day.date.month, year: day.date.year) },
          summary: course.name,
          description: course.description.gsub(/<[\/\w]*>/, '') + "\n\nImportant Notes:\n" + course.notes
        }
        rsp = gclient.execute(
          api_method: gcal.events.insert,
          parameters: { 'calendarId' => params[:calendar] },
          body: JSON.dump(event).gsub('Z', "#{organization.timezone}"),
          headers: { 'Content-Type' => 'application/json' }
        )
      end
    end
    render json: { success: true }
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
