require 'redmine'
require_dependency 'custom_field'

Redmine::Plugin.register :redmine_secretary do
  name 'Secretary'
  author 'Roman Shipiev'
  description 'The plugin registers incoming and outgoing correspondence of one or more organizations. '
  version '0.1.9'
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

  menu :admin_menu, :organizations,
    {:controller => :organizations, :action => :index},
    :caption => :label_organization_plural, :html => {:class => :enumerations}

#  menu :admin_menu, :secretary_members,
#    {:controller => :secretary_members, :action => :index},
#    :caption => :label_secretary_member_plural, :html => {:class => :users}
#
#  menu :admin_menu, :secretary_projects,
#    {:controller => :secretary_projects, :action => :index},
#    :caption => :label_secretary_project_plural, :html => {:class => :enumerations}

  settings :default => {
                         :issue_tracker => Tracker.first.id,
                         :issue_priority => IssuePriority.default.id,
                         :issue_status => IssueStatus.default.id
                       },
           :partial => 'incoming_letters/settings'
end
