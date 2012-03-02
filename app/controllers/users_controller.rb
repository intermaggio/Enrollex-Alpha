class UsersController < InheritedResources::Base

  def remove_camper
    Camper.find(params[:id]).destroy
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
    unless user.salt
      auto_login user
      remember_me!
      user.update_attribute(:password, params[:password])
      cookies[:cm_user_id] = user.id
      cookies[:cm_hash] = user.salt.to_i(36)
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
    if params[:user][:birthday]
      birthday = params[:user][:birthday].split(/\W/)
      @user.birthday = Date.parse birthday[1] + '-' + birthday[0] + '-' + birthday[2]
    end
    if @user.save
      auto_login @user
      remember_me!
      if params[:type] == 'children'
        redirect_to '/signup/add_child', flash: { info: { street: @user.street, city: @user.city, state: @user.state, zip: @user.zip } }
      else
        redirect_to '/'
      end
    else
      render 'signup'
    end
  end

  def update_camper
    @camper = Camper.find params[:id]
    @camper.update_attributes params[:camper]
    if params[:camper][:birthday]
      birthday = params[:camper][:birthday].split(/\W/)
      @camper.birthday = Date.parse birthday[1] + '-' + birthday[0] + '-' + birthday[2]
    end
    respond_to :js
  end

  def create_camper
    @camper = current_user.campers.new params[:camper]
    if params[:camper][:birthday]
      birthday = params[:camper][:birthday].split(/\W/)
      @camper.birthday = Date.parse birthday[1] + '-' + birthday[0] + '-' + birthday[2]
    end
    if @camper.save
      if params[:submission_type] == 'complete'
        redirect_to '/'
      elsif params[:submission_type] == 'update'
        respond_to :js
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
      cookies[:cm_user_id] = user.id
      cookies[:cm_hash] = user.salt.to_i(36)
      redirect_to '/'
    else
      @fail = true
      render 'site/organization'
    end
  end

  def signout
    logout
    cookies[:cm_user_id] = nil
    cookies[:cm_hash] = nil
    redirect_to '/'
  end

  def signup
    case params[:type]
      when 'adult'
        render 'signup_adult'
      when 'children'
        render 'signup_children'
      when 'email'
        if User.find(params[:id]).salt
          redirect_to '/'
        else
          render 'signup_email'
        end
    end
  end

end
