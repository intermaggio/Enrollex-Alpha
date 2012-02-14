class UsersController < InheritedResources::Base

  def create_instructor
    @user = User.where(email: params[:user][:email]).first || User.new(params[:user])
    @user.instructing_for << Organization.find(params[:oid])
    params[:courses].each do |course_hash|
      @user.instructing << Course.find(course_hash.first) if course_hash.last == '1'
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
    @user.birthday = Date.parse params[:user][:birthday].gsub(/\W/, '-') if params[:user][:birthday]
    if @user.save
      auto_login @user
      remember_me!
      if params[:type] == 'adult'
        redirect_to '/'
      else
        redirect_to '/signup/add_child', flash: { info: { street: @user.street, city: @user.city, state: @user.state, zip: @user.zip } }
      end
    else
      render 'signup'
    end
  end

  def create_camper
    @camper = current_user.campers.new params[:camper]
    @camper.birthday = Date.parse params[:camper][:birthday]
    if @camper.save
      if params[:submission_type] == 'complete'
        redirect_to '/'
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
      redirect_to '/'
    else
      render inline: 'fail'
    end
  end

  def signout
    logout
    cookies[:cm_user_id] = nil
    redirect_to '/'
  end

  def signup
    if params[:type] == 'adult'
      render 'signup_adult'
    elsif params[:type] == 'children'
      render 'signup_children'
    end
  end

end
