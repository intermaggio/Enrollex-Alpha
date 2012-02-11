CourseManage::Application.routes.draw do

  get '/signup' => 'users#signup'
  get '/signout' => 'users#signout'
  get '/signup_organization' => 'users#signup_organization'

  get '/signup/:action' => 'users'

  match '/courses/:id/:action' => 'courses'
  get '/admin/courses/:id/:lowname' => 'admin#manage_course'

  match '/:controller/:action'
  match '/:action' => 'site'
  root to: 'site#index'

end
