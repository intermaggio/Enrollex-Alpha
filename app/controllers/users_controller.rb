class UsersController < InheritedResources::Base

  def create
    User.create(params[:user])
    redirect_to '/'
  end

  def auth
    if user = login(params[:email], params[:password], true)
      redirect_to '/'
    else
      render inline: 'fail'
    end
  end

  def signup
  end

end
