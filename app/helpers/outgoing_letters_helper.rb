module OutgoingLettersHelper
  def outgoing_letter_heading(object)
    [t(:field_outgoing_code), object.outgoing_code, t(:dated), format_date(object.created_on)].join(' ')
  end

  def related_projects
    Member.where(:user_id => User.current.id).includes(&:project).all.
        map(&:project).select(&:active?)
#    Project.active.visible.all
  end

  def time_periods
    %w{last_week this_week last_month this_month last_year this_year}
  end

  def project_id_for_select
    Project.active.visible.all
  end
end
