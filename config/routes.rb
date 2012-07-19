ActionController::Routing::Routes.draw do |map|
  map.resources :incoming_letters
  map.resources :outgoing_letters
  map.resources :organizations
  map.resources :secretary_members, :except => :show
end
