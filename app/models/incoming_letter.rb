class IncomingLetter < ActiveRecord::Base
  unloadable
  include Redmine::SafeAttributes  
  
  belongs_to  :author, :class_name => 'User', :foreign_key => 'author_id'  
  belongs_to  :executor, :class_name => 'User', :foreign_key => 'executor_id'  
  belongs_to  :organization
  has_many    :projects, :through => :associated_projects
  has_many    :associated_projects
  has_many    :comments, :as => :commented, :dependent => :destroy

  validates_presence_of :incoming_code, :author_id, :executor_id, 
    :shipping_type, :shipping_from, :organization_id
  validates_format_of :incoming_code, :with => /^\d+\-\d{2}(\/\d+)?$/,
    :message => I18n.t(:message_incorrect_format_incoming_code)
  validates_uniqueness_of :incoming_code, :scope => :organization_id
  validate :incoming_code_incorrect_year
  validate :incoming_code_in_series, :on => :create
  validate :answer_for_exist
  validates_presence_of :projects, :files, :on => :create  

  acts_as_attachable
  
  attr_accessor :project, :projects, :files, :subject  
  
  safe_attributes :incoming_code, :outgoing_code, :answer_for, :signer,
    :shipping_from, :shipping_type, :shipping_on, :subject,
    :original_required, :recipient, :executor_id, :description, 
    :organization_id

  named_scope :this_organization, lambda {|q|
    if q.present?
      {:conditions => ["organization_id=?", q]}
    end
  }

  named_scope :time_period, lambda {|q, field|
    today = Date.today
    if q.present? && field.present?
      {:conditions => 
        (case q
          when "yesterday"
            ["#{field} BETWEEN ? AND ?", 
              2.days.ago, 
              1.day.ago]
          when "today"
            ["#{field} BETWEEN ? AND ?", 
              1.day.ago, 
              1.day.from_now]
          when "last_week"
            ["#{field} BETWEEN ? AND ?", 
              1.week.ago - today.wday.days, 
              1.week.ago - today.wday.days + 1.week]
          when "this_week"       
            ["#{field} BETWEEN ? AND ?", 
              1.week.from_now - today.wday.days - 1.week, 
              1.week.from_now - today.wday.days]
          when "last_month"
            ["#{field} BETWEEN ? AND ?", 
              1.month.ago - today.day.days, 
              1.month.ago - today.day.days + 1.month]
          when "this_month"
            ["#{field} BETWEEN ? AND ?", 
              1.month.from_now - today.day.days - 1.month, 
              1.month.from_now - today.day.days]
          when "last_year"       
            ["#{field} BETWEEN ? AND ?", 
              1.year.ago - today.yday.days, 
              1.year.ago - today.yday.days + 1.year]
          when "this_year"
            ["#{field} BETWEEN ? AND ?", 
              1.year.from_now - today.yday.days - 1.year, 
              1.year.from_now - today.yday.days]
          else
            {}
        end)
      }
    end
  }

  named_scope :like_executor, lambda {|q|
    if q.present?
      {:conditions => 
        ["LOWER(users.firstname) LIKE :p OR users.firstname LIKE :p OR LOWER(users.lastname) LIKE :p OR users.lastname LIKE :p", 
        {:p => "%#{q.to_s.downcase}%"}],
       :include => :executor}
    end
  }
  
  named_scope :like_field, lambda {|q, field|
    if q.present? && field.present?
      {:conditions => 
        ["LOWER(#{field}) LIKE :p OR #{field} LIKE :p", 
        {:p => "%#{q.to_s.downcase}%"}]}
    end
  }  

  named_scope :eql_field, lambda {|q, field|
    if q.present? && field.present?
      {:conditions => {field => q}}
    end
  }  

  def incoming_code_incorrect_year
    regexp = /^(\d+)-(\d{2})(\/\d+)?$/
    if incoming_code[regexp]
      return if incoming_code[regexp,2].to_i <= Time.now.strftime("%y").to_i
    end
    errors.add(:incoming_code, :incorrect_year)
  end  

  def incoming_code_in_series
    regexp = /^(\d+)-(\d{2})(\/\d+)?$/
    if incoming_code[regexp]
      return if created_on.present?
      return if incoming_code[regexp,3].present?
      return if incoming_code[regexp,2].to_i < Time.now.strftime("%y").to_i
      return if previous_code.blank?
      return if incoming_code[regexp,1] == previous_code.value.succ
    end
    errors.add(:incoming_code, :in_series)
  end

  def answer_for_exist
    if self.answer_for.present?
      if OutgoingLetter.find(:first, :conditions => {
        :outgoing_code => self.answer_for, 
        :organization_id => self.organization_id}).blank?
        
        errors.add(:answer_for, :not_exist)
      end
    end
  end
  
  def previous_code
    PreviousCode.find(:last, :conditions => {
      :name => self.class.name.underscore, 
      :year => Time.now.strftime("%y"),
      :organization_id => self.organization_id
    })
  end

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
      map{ |project|
        create_issue(project)
      }
  end

  def create_issue(project)
    settings = Setting[:plugin_redmine_secretary]
    issue = Issue.create(
      :status => IssueStatus.find(settings[:issue_status]), 
      :tracker => Tracker.find(settings[:issue_tracker]), 
      :subject => issue_subject, 
      :project => project, 
      :description => description, 
      :author => User.current, 
      :start_date => Date.today,
      :due_date => next_work_day,
      :priority => IssuePriority.find(settings[:issue_priority]),
      :assigned_to => executor)
      
    attachments.each do |attachment| 
      attachment.copy(
        :container_id => issue.id, 
        :container_type => issue.class.name
      ).save
    end
    issue
  end        
  
  def next_work_day(now_day = Date.today)
    next_day = now_day + 1.day
    case next_day.wday
      when 6
        next_day + 1.day
      when 5
        next_day + 2.days      
      else
        next_day
    end
  end
  
  def issue_subject
    if subject.present?
      subject
    else
      options = to_hash
      options = I18n.t(:incoming_issue_subject).
        scan(/%\{.*?\}/).
        map{ |str| str[2..-2] }.
        inject({}){ |result, name| 
          result.merge name.to_sym => options[name] 
        }              
      I18n.t(:incoming_issue_subject, options)
    end
  end    
end
