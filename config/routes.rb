ActionController::Routing::Routes.draw do |map|
  map.resources :incoming_letters
  map.resources :outgoing_letters
end
