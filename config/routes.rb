Enrollex::Application.routes.draw do

  get '/signup' => 'users#signup'
  get '/signout' => 'users#signout'
  get '/signup_organization' => 'users#signup_organization'

  get '/signup/:action' => 'users'

  post '/courses/:id/:action' => 'courses'
  get '/courses/:id/:lowname' => 'courses#show'
  match '/admin/courses/:id/:action' => 'admin'

  match '/:controller/:action'
  match '/:action' => 'site'
  root to: 'site#index'

end
