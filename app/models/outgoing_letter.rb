class OutgoingLetter < ActiveRecord::Base
  unloadable
  include Redmine::SafeAttributes

  belongs_to  :author, class_name: 'User', foreign_key: 'author_id'
  belongs_to  :organization
  has_many    :outgoing_projects
  has_many    :projects, through: :outgoing_projects

  has_many    :comments, as: :commented, dependent: :destroy

  validates_presence_of :outgoing_code, :author_id,
    :shipping_type, :shipping_to, :shipping_on, :organization_id, :subject
  validates_presence_of :files, on: :create
  validates_format_of :outgoing_code, with: /^\d+\-\d{2}(\/\d+)?$/,
    message: I18n.t(:message_incorrect_format_outgoing_code)
  validates_uniqueness_of :outgoing_code, scope: :organization_id
  validate :outgoing_code_incorrect_year
  validate :outgoing_code_in_series, on: :create
  validate :answer_for_exist

  before_save :add_author_id

  acts_as_attachable
#  view_permission: :view_outgoing_letters, delete_permission: :delete_outgoing_letters

  attr_accessor :project, :files, :signer_user_id

  safe_attributes :outgoing_code, :incoming_code, :answer_for, :signer,
    :shipping_to, :shipping_type, :shipping_on, :subject,
    :served_on, :recipient, :description, :organization_id, :signer_user_id

  scope :for_project, lambda{ |q|
    if q.present? && q.try(:id)
      joins(:outgoing_projects).where("#{OutgoingProject.table_name}.project_id = ?",q.id)
    end
  }

  scope :this_organization, lambda {|q|
    if q.present?
      where("organization_id=?", q)
    end
  }

  scope :time_period, lambda {|q, field|
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

  scope :like_field, lambda {|q, field|
    if q.present? && field.present?
      where("LOWER(#{field}) LIKE :p OR #{field} LIKE :p",
        p: "%#{q.to_s.downcase}%")
    end
  }

  scope :eql_field, lambda {|q, field|
    if q.present? && field.present?
      where(field => q)
    end
  }

  scope :eql_created_on, lambda {|q|
    if q.present?
      where("DATE(created_on) = ?",q)
    end
  }

  def outgoing_code_incorrect_year
    regexp = /^(\d+)-(\d{2})(\/\d+)?$/
    if outgoing_code[regexp]
      return if outgoing_code[regexp,2].to_i <= Time.now.strftime("%y").to_i
    end
    errors.add(:outgoing_code, :incorrect_year)
  end

  def outgoing_code_in_series
    regexp = /^(\d+)-(\d{2})(\/\d+)?$/
    if outgoing_code[regexp]
      return if created_on.present?
      return if outgoing_code[regexp,3].present?
      return if outgoing_code[regexp,2].to_i < Time.now.strftime("%y").to_i
      return if previous_code.blank?
      return if outgoing_code[regexp,1] == previous_code.value.succ
    end
    errors.add(:outgoing_code, :in_series)
  end

  def answer_for_exist
    if self.answer_for.present?
      if IncomingLetter.where(
          incoming_code: self.answer_for,
          organization_id: self.organization_id
        ).first

        errors.add(:answer_for, :not_exist)
      end
    end
  end

  def previous_code
    PreviousCode.find(:last, :conditions => {
      name: self.class.name.underscore,
      year: Time.now.strftime("%y"),
      organization_id: self.organization_id
    })
  end

  def attachments_visible?(user=User.current)
    true
#    user.allowed_to?(self.class.attachable_options[:view_permission], nil, :global => true)
  end

  def attachments_deletable?(user=User.current)
    user.allowed_to?(self.class.attachable_options[:delete_permission], nil, global: true)
  end

  def editable_by?(usr)
    usr && usr.logged? && (usr.allowed_to?(:edit_outgoing_letters, nil, global: true) || (self.author == usr && usr.allowed_to?(:edit_own_outgoing_letters, nil, global: true))
    )
  end

  def destroyable_by?(usr)
    usr && usr.logged? && (usr.allowed_to?(:delete_outgoing_letters, nil, global: true) || (self.author == usr && usr.allowed_to?(:delete_own_outgoing_letters, nil, global: true))
    )
  end

  def add_author_id
    self.author = User.current
  end
end
