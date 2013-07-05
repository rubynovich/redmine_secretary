module IncomingLettersHelper
  def incoming_letter_heading(object)
    [t(:field_incoming_code), object.incoming_code, t(:dated), format_date(object.created_on)].join(' ')
  end

  def related_projects
    Member.where(:user_id => User.current.id).includes(&:project).all.
        map(&:project).select(&:active?)
  end

  def project_members
    related_projects.
      map{ |project|
        Member.where(:project_id => project.id).includes(&:user).all.map(&:user)
      }
  end

  def possible_executors
    project_members.
      inject(project_members.flatten){ |result, arr| result & arr }.
      compact
  end

  def time_periods
    %w{yesterday last_week this_week last_month this_month last_year this_year}
  end

  def project_id_for_select
    Project.active.visible.all
  end
end
