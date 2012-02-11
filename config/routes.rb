CourseManage::Application.routes.draw do

  get '/signup' => 'users#signup'
  get '/signout' => 'users#signout'
  get '/org_signup' => 'users#org_signup'

  get '/signup/:action' => 'users'

  match '/course/:lowname/:action' => 'courses'
  get '/admin/courses/:lowname' => 'admin#manage_course'

  match '/:controller/:action'
  match '/:action' => 'site'
  root to: 'site#index'

end
