Enrollex::Application.routes.draw do

  get '/signup' => 'users#signup'
  get '/signout' => 'users#signout'
  get '/signup_organization' => 'users#signup_organization'

  get '/signup/:action' => 'users'

  post '/courses/:id/:action' => 'courses'
  get '/courses/:id/:lowname' => 'courses#show'
  get '/courses/:id/:lowname/:action' => 'courses'
  match '/admin/courses/create' => 'admin#create'
  match '/admin/courses/:id' => 'admin#manage_course'
  match '/admin/courses/:id/:action' => 'admin'

  match '/:controller/:action'
  match '/:action' => 'site'
  root to: 'site#index'

end
