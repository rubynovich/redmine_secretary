require 'redmine'

Redmine::Plugin.register :redmine_secretary do
  name 'Redmine Secretary plugin'
  author 'Roman Shipiev'
  description 'Plugin for the registration of incoming and outgoing documents'
  version '0.0.7'
  url 'https://github.com/rubynovich/redmine_secretary'
  author_url 'http://roman.shipiev.me'
  
  permission :view_incoming_letters,  :incoming_letters => [:index, :show]
  permission :add_incoming_letters,   :incoming_letters => [:new, :create]
  permission :edit_incoming_letters,  :incoming_letters => [:edit, :update]
  permission :edit_own_incoming_letters,  :incoming_letters => [:edit, :update]  
  permission :delete_incoming_letters, :incoming_letters => :destroy
  permission :delete_own_incoming_letters,  :incoming_letters => :destroy
  permission :view_outgoing_letters,  :outgoing_letters => [:index, :show]
  permission :add_outgoing_letters,   :outgoing_letters => [:new, :create]
  permission :edit_outgoing_letters,  :outgoing_letters => [:edit, :update]
  permission :edit_own_outgoing_letters,  :outgoing_letters => [:edit, :update]      
  permission :delete_outgoing_letters, :outgoing_letters => :destroy
  permission :delete_own_outgoing_letters, :outgoing_letters => :destroy
    
  menu :application_menu, :incoming_letters, {:controller => :incoming_letters, :action => :index}, :caption => :label_incoming, :param => :project_id, :if => Proc.new{User.current.allowed_to?({:controller => :incoming_letters, :action => :index}, nil, {:global => true})}
  
  menu :application_menu, :outgoing_letters, {:controller => :outgoing_letters, :action => :index}, :caption => :label_outgoing, :param => :project_id, :if => Proc.new{ User.current.allowed_to?({:controller => :outgoing_letters, :action => :index}, nil, {:global => true})}
end
