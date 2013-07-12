module OutgoingLettersHelper
  def outgoing_letter_heading(object)
    [t(:field_outgoing_code), object.outgoing_code, t(:dated), format_date(object.created_on)].join(' ')
  end

  def related_projects
    settings = Setting[:plugin_redmine_secretary]
    begin
      Principal.find(settings[:assigned_to_id]).projects.order(:name)
    rescue
#    Project.active.visible.all
      Member.where(:user_id => User.current.id).includes(&:project).all.
          map(&:project).select(&:active?).sort_by(&:name)
    end
  end

  def time_periods
    %w{last_week this_week last_month this_month last_year this_year}
  end

#  def project_id_for_select
#    Project.active.all
#  end
end
