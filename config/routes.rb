Myturf::Application.routes.draw do

  get '/signup' => 'users#signup'

  match '/:controller/:action'
  match '/:action' => 'site'
  root to: 'site#index'

end
