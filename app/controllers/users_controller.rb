class UsersController < InheritedResources::Base

  def reset_pass
    user = User.where(email: params[:email]).first
    if user
      Pony.mail(
        to: user.email,
        from: 'robot@enrollex.org',
        subject: 'Reset Password',
        body: "Visit the following link to reset your enrollex password:<br/><br/>http://enrollex.org/users/reset_password?id=#{user.id}&hash=#{user.hash.abs}&org=#{organization.id}",
        headers: { 'Content-Type' => 'text/html' },
        via: :smtp,
        via_options: {
          address: 'smtp.gmail.com',
          port: '587',
          enable_starttls_auto: true,
          user_name: 'robot@enrollex.org',
          password: 'b0wserFire',
          authentication: :plain,
          domain: 'enrollex.org'
        }
      )
      respond_to :js
    else
      respond_to do |format|
        format.js { render 'reset_pass_fail' }
      end
    end
  end

  def remove_camper
    User.find(params[:id]).destroy
    render json: { success: true }
  end

  def gen_camper_form
    render layout: false
  end

  def update
    if params[:old_pass].present? && !login(current_user.email, params[:old_pass], true)
      redirect_to request.referrer, notice: :fail
    else
      current_user.update_attributes params[:user]
      redirect_to request.referrer, notice: :success
    end
  end

  def create_password
    user = User.find params[:id]
    unless false
      auto_login user
      remember_me!
      user.change_password! params[:pass]
      user.save
      #cookies[:cm_user_id] = user.id
      #cookies[:cm_hash] = user.salt.to_i(36)
      #session[:cm_user_id] = cookies[:cm_user_id]
      #session[:cm_hash] = cookies[:cm_hash]
    end
    redirect_to '/'
  end

  def create_instructor
    @user = User.where(email: params[:user][:email]).first || User.new(params[:user])
    @user.instructing_for << Organization.find(params[:oid])
    if params[:courses]
      params[:courses].each do |hash|
        @user.instructing << Course.find(hash.first) if hash.last == '1'
      end
    end
    if @user.save
      redirect_to '/admin/instructors'
    else
      render 'admin/instructors'
    end
  end

  def create_organization
    @user = User.new params[:user]
    @organization = Organization.new params[:organization]
    if @user.save && @organization.save
      auto_login @user
      remember_me!
      @organization.admins << @user
      redirect_to 'http://' + @organization.subname + '.' + request.domain
    else
      @user.destroy
      @organization.destroy
      render 'users/signup_organization'
    end
  end

  def create_adult
    @user = User.new params[:user]
    @user.timezone = @user.timezone.match(/((-|\+)\d{2}:\d{2})/).captures.first
    if params[:user][:birthday]
      birthday = params[:user][:birthday].split(/\W/)
      @user.birthday = birthday[1] + '/' + birthday[0] + '/' + birthday[2]
    end
    if @user.save
      Pony.mail(
        to: @user.email,
        from: 'robot@enrollex.org',
        subject: "#{organization.email_subject}",
        body: "#{RedCloth.new(organization.email_message, [:filter_html, :bbcode]).to_html}",
        headers: { 'Content-Type' => 'text/html' },
        via: :smtp,
        via_options: {
          address: 'smtp.gmail.com',
          port: '587',
          enable_starttls_auto: true,
          user_name: 'robot@enrollex.org',
          password: 'b0wserFire',
          authentication: :plain,
          domain: 'enrollex.org'
        }
      )
      auto_login @user
      remember_me!
      if params[:type] == 'children'
        redirect_to '/users/add_child', flash: { info: { street: @user.street, city: @user.city, state: @user.state, zip: @user.zip } }
      else
        redirect_to '/'
      end
    else
      if params[:type] == 'children'
        render 'signup_children'
      else
        render 'signup_adult'
      end
    end
  end

  def update_camper
    @camper = User.find params[:id]
    @camper.update_attributes params[:camper]
    if params[:camper][:birthday]
      birthday = params[:camper][:birthday].split(/\W/)
      @camper.update_attribute(:birthday, birthday[1] + '/' + birthday[0] + '/' + birthday[2])
    end
    redirect_to '/profile', notice: 'success'
  end

  def create_camper
    @camper = current_user.campers.new params[:camper]
    if params[:camper][:birthday]
      birthday = params[:camper][:birthday].split(/\W/)
      @camper.birthday = birthday[1] + '/' + birthday[0] + '/' + birthday[2]
    end
    if @camper.save
      if params[:submission_type] == 'complete'
        redirect_to '/'
      elsif params[:submission_type] == 'update'
        redirect_to '/profile', notice: 'success'
      else
        redirect_to '/signup/add_child', flash: { info: { street: current_user.street, city: current_user.city, state: current_user.state, zip: current_user.zip } }
      end
    else
      render 'add_child'
    end
  end

  def auth
    if user = login(params[:email], params[:password], true)
      remember_me!
      #cookies[:cm_user_id] = user.id
      #cookies[:cm_hash] = user.salt.to_i(36)
      #session[:cm_user_id] = cookies[:cm_user_id]
      #session[:cm_hash] = cookies[:cm_hash]
      redirect_to request.referrer
    else
      redirect_to request.referrer, flash: { auth_fail: true }
    end
  end

  def signout
    logout
    #cookies[:cm_user_id] = nil
    #cookies[:cm_hash] = nil
    #session[:cm_hash] = nil
    #session[:cm_user_id] = nil
    redirect_to '/'
  end

  def signup
    case params[:type]
      when 'adult'
        render 'signup_adult'
      when 'children'
        render 'signup_children'
      when 'email'
        user = User.find(params[:id])
        if user.hash.abs == params[:hash].to_i
          render 'signup_email'
        else
          redirect_to '/'
        end
    end
  end

  def reset_password
    user = User.find(params[:id])
    begin
      org = Organization.find(params[:org])
      redirect_to "http://#{org.subname}.enrollex.org" if user.hash.abs != params[:hash].to_i
    rescue
      redirect_to '/' if user.hash.abs != params[:hash].to_i
    end
  end

end
