module IncomingLettersHelper
  def incoming_letter_heading(object)  
    [t(:field_incoming_code), object.incoming_code, t(:dated), format_date(object.created_on)].join(' ')
  end
  
  def related_projects
    Member.find(:all, :conditions => {:user_id => User.current.id}).
        map{ |m| m.project }
  end
  
  def project_members
    related_projects.
      map{ |project| 
        Member.
          find(:all, :conditions => {:project_id => project.id}).
          map{ |m| m.user } 
      }
  end
  
  def possible_executors
    project_members.
      inject(project_members.flatten){ |result, arr| result & arr }
  end
  
  def time_periods
    %w{last_week this_week last_month this_month last_year this_year}
  end
end
