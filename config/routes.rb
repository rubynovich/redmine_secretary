ActionController::Routing::Routes.draw do |map|
  map.resources :incoming_letters, :collection => {:clean_previous_code => :get}
  map.resources :outgoing_letters, :collection => {:clean_previous_code => :get}
end
