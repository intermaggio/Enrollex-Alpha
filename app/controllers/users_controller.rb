class UsersController < InheritedResources::Base

  def create
    @user = User.new params[:user]
    @organization = Organization.new params[:organization] if params[:organization]
    if @user.save && (defined?(@organization) && @organization.save || !defined?(@organization))
      auto_login @user
      if defined?(@organization)
        @organization.admins << @user
        redirect_to 'http://' + @organization.subname + '.' + request.domain
      else
        redirect_to '/'
      end
    else
      if defined?(@organization)
        render 'users/org_signup'
      else
        render 'users/signup'
      end
    end
  end

  def auth
    if user = login(params[:email], params[:password], true)
      redirect_to '/'
    else
      render inline: 'fail'
    end
  end

  def signout
    logout
    redirect_to '/'
  end

  def signup
  end

  def org_signup
  end

end
