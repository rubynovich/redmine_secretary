class IncomingLetter < ActiveRecord::Base
  unloadable
  include Redmine::SafeAttributes  
  
  belongs_to  :author, :class_name => 'User', :foreign_key => 'author_id'  
  belongs_to  :executor, :class_name => 'User', :foreign_key => 'executor_id'  
  has_many    :projects, :through => :associated_projects
  has_many    :associated_projects
  has_many    :comments, :as => :commented, :dependent => :destroy

  validates_presence_of :incoming_code, :author_id, :executor_id, 
    :shipping_type, :shipping_from, :projects, :files
  validates_format_of :incoming_code, :with => /^\d+\-\d{2}(\/\d+)?$/,
    :message => I18n.t(:message_incorrect_format_incoming_code)
  validates_uniqueness_of :incoming_code
  validate :incoming_code_incorrect_year
#  validate :incoming_code_in_series  

  acts_as_attachable
  
  attr_accessor :project, :projects, :files  
  
  safe_attributes :incoming_code, :outgoing_code, :signer,
    :shipping_from, :shipping_type, :shipping_on, 
    :original_required, :recipient, :executor_id, :description

  def incoming_code_incorrect_year
    regexp = /^(\d+)-(\d{2})(\/\d+)?$/
    if incoming_code[regexp]
      return if incoming_code[regexp,2].to_i <= Time.now.strftime("%y").to_i
    end
    errors.add(:incoming_code, :incorrect_year)
  end

#  def incoming_code_in_series
#    regexp = /^(\d+)-(\d{2})(\/\d+)?$/
#    if incoming_code[regexp]
#      return if incoming_code[regexp,3].present?
#      return if incoming_code[regexp,2] <= Time.now.strftime("%y")
#      return if incoming_code[regexp,1] == PreviousCode.find_by_name(:incoming_letter).value.succ
#    end
#    errors.add(:incoming_code, :in_series)
#  end

  def attachments_visible?(user=User.current)
      user.allowed_to?(self.class.attachable_options[:view_permission], nil, :global => true)
  end

  def attachments_deletable?(user=User.current)
    user.allowed_to?(self.class.attachable_options[:delete_permission], nil, :global => true)
  end
       
  def editable_by?(usr)
    usr && usr.logged? && (usr.allowed_to?(:edit_incoming_letters, nil, :global => true) || (self.author == usr && usr.allowed_to?(:edit_own_incoming_letters, nil, :global => true))
    )
  end

  def destroyable_by?(usr)
    usr && usr.logged? && (usr.allowed_to?(:delete_incoming_letters, nil, :global => true) || (self.author == usr && usr.allowed_to?(:delete_own_incoming_letters, nil, :global => true))
    )
  end
  
  def to_hash
    self.class.column_names.map{ |name| name.sub(/_id$/,'') }.
      inject({}) { |result, name| 
        result.merge name => self.send(name)
      }
  end

  def create_issues
    projects.
      map{ |key| Project.find(key) }.
      each{ |project|
        create_issue(project)
      }
  end

  def create_issue(project)
    settings = Setting[:plugin_redmine_secretary]
    issue = Issue.create(
      :status => IssueStatus.default, 
      :tracker => project.trackers[settings[:issue_tracker]], 
      :subject => issue_subject, 
      :project => project, 
      :description => description, 
      :author => User.current, 
      :start_date => Date.today,
      :due_date => next_work_day,
      :priority => IssuePriority.active[settings[:issue_priority]],
      :assigned_to => executor)
      
    attachments.each do |attachment| 
      attachment.copy(
        :container_id => issue.id, 
        :container_type => issue.class.name
      ).save
    end
  end        
  
  def next_work_day(now_day = Date.today)
    next_day = now_day + 1.day
    case next_day.wday
      when 0
        next_day + 1.day
      when 6
        next_day + 2.days      
      else
        next_day
    end
  end
  
  def issue_subject
    options = to_hash
    options = I18n.t(:incoming_issue_subject).
      scan(/%\{.*?\}/).
      map{ |str| str[2..-2] }.
      inject({}){ |result, name| 
        result.merge name.to_sym => options[name] 
      }              
    I18n.t(:incoming_issue_subject, options)
  end    

#  def save_attachments(params)
#    if valid?
#      attachments = Attachment.attach_files(self, params)
#      begin
#        raise ActiveRecord::Rollback unless save
#      rescue ActiveRecord::StaleObjectError
#        attachments[:files].each(&:destroy)
#        errors.add :base, l(:notice_locking_conflict)
#        raise ActiveRecord::Rollback
#      end
#    end  
#  end  
end
