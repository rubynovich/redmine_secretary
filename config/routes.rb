if Rails::VERSION::MAJOR >= 3
  RedmineApp::Application.routes.draw do
    resources :incoming_letters do
      collection do
        get :autocomplete_for_signer
        get :autocomplete_for_recipient
        get :autocomplete_for_shipping_from
      end
    end
    resources :outgoing_letters do
      collection do
        get :autocomplete_for_signer
        get :autocomplete_for_recipient
        get :autocomplete_for_shipping_to
      end
    end
    resources :organizations
    resources :secretary_members, :except => :show
    resources :secretary_projects, :except => :show
  end
else
  ActionController::Routing::Routes.draw do |map|
    map.resources :incoming_letters
    map.resources :outgoing_letters
    map.resources :organizations
    map.resources :secretary_members, :except => :show
    map.resources :secretary_projects, :except => :show
  end
end
