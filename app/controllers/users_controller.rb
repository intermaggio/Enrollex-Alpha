class UsersController < InheritedResources::Base

  def create
    @user = User.new params[:user]
    @organization = Organization.new params[:organization] if params[:organization]
    if @user.save && (defined?(@organization) && @organization.save || !defined?(@organization))
      params[:campers].each do |camper|
        camper = Camper.new camper.last
        camper.user = @user
        camper.save
      end
      auto_login @user
      if defined?(@organization)
        @organization.admins << @user
        redirect_to 'http://' + @organization.subname + '.' + request.domain
      else
        redirect_to '/'
      end
    else
      @user.destroy
      if defined?(@organization)
        @organization.destroy
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

  def gen_camper
    render partial: 'camper', locals: { num: params[:num] }
  end

  def signup
  end

  def org_signup
  end

end
