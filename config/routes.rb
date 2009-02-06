ActionController::Routing::Routes.draw do |map|
  map.resources :sites
 
  # Restful Authentication Rewrites
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate', :activation_code => nil
  map.forgot_password '/forgot_password', :controller => 'passwords', :action => 'new'
  map.change_password '/change_password/:reset_code', :controller => 'passwords', :action => 'reset'
  
  # Restful Authentication Resources
  map.resources :users
  map.resources :passwords
  map.resource :session
  #map.resources :trees
  map.resources(:lines, :controller => 'line') do |l|
    l.resources :bets
  end
  map.resources :main
  map.resources :game
  map.resources :periods, :controller => 'period'
  map.resources :summary, :controller => 'summary'
  map.connect 'game/:away/:home/:date', :controller => 'game', :action => 'show'
  map.resources :games, :controller => :game
  map.resources :daily_summary, :controller => :daily_summary
  map.resources :make_bets, :controller => :make_bets
  
  # Home Page
  map.root :controller => 'sessions', :action => 'new'

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action'
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
