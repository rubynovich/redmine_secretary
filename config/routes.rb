ActionController::Routing::Routes.draw do |map|
  map.resources :incoming_letters, :collection => {
    :clean_previous_code => :get,
    :autocomplete_for_incoming_letter_shipping_from => :get,
    :autocomplete_for_incoming_letter_signer => :get,
    :autocomplete_for_incoming_letter_recipient => :get    
  }
  map.resources :outgoing_letters, :collection => {
    :clean_previous_code => :get,
    :autocomplete_for_incoming_letter_shipping_to => :get,
    :autocomplete_for_incoming_letter_signer => :get,
    :autocomplete_for_incoming_letter_recipient => :get
  }
end
