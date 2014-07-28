module IncomingLettersHelper
  def incoming_letter_heading(object)
    [t(:field_incoming_code), object.incoming_code, t(:dated), format_date(object.created_on)].join(' ')
  end

  def shipping_type_with_courier(object)
    if object.shipping_type == Setting[:plugin_redmine_secretary][:shipping_type] && !object.courier.nil?
      h(object.shipping_type) + " (" + l(:field_courier_context) + ": " + link_to_user(object.courier) + ")"
    else
      h(object.shipping_type)
    end
  end

  def related_projects
    settings = Setting.plugin_redmine_secretary
    begin
      Principal.find(settings[:assigned_to_id]).projects.order(:name)
    rescue
#    Project.active.visible.all
      Member.where(user_id: User.current.id).includes(&:project).all.
          map(&:project).select(&:active?).sort_by(&:name)
    end
  end

  def project_members
    related_projects.
      map{ |project|
        Member.where(project_id: project.id).includes(&:user).all.map(&:user)
      }
  end

  def possible_executors
    settings = Setting.plugin_redmine_secretary
    begin
      principal = Principal.find(settings[:assigned_to_id])
      principal.kind_of?(Group) ? principal.users : [principal]
    rescue
      project_members.
        inject(project_members.flatten){ |result, arr| result & arr }.
        compact
    end
  end

  def executor_id_for_select
    User.where("#{User.table_name}.id IN (SELECT #{IncomingLetter.table_name}.executor_id FROM #{IncomingLetter.table_name} WHERE #{IncomingLetter.table_name}.executor_id = #{User.table_name}.id)")
  end

  def time_periods
    %w{yesterday last_week this_week last_month this_month last_year this_year}
  end

#  def project_id_for_select
#    Project.active.visible.all
#  end
end
