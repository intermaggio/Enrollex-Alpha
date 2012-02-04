CourseManage::Application.routes.draw do

  get '/signup' => 'users#signup'
  get '/signout' => 'users#signout'
  get '/org_signup' => 'users#org_signup'

  match '/course/:lowname/:action' => 'courses'

  match '/:controller/:action'
  match '/:action' => 'site'
  root to: 'site#index'

end
