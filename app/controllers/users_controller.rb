class UsersController < InheritedResources::Base

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
    if @user.save
      auto_login @user
      remember_me!
      if params[:type] == 'adult'
        redirect_to '/'
      else
      end
    else
      render inline: 'You wanted awesome, and we gave you fail :(.'
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

  def gen_camper
    render partial: 'camper', locals: { num: params[:num] }
  end

  def signup
    if params[:type] == 'adult'
      render 'signup_adult'
    elsif params[:type] == 'children'
      render 'signup_children'
    end
  end

  def org_signup
  end

end
