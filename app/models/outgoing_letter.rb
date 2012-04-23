class OutgoingLetter < ActiveRecord::Base
  unloadable
  include Redmine::SafeAttributes    
  
  belongs_to  :author, :class_name => 'User', :foreign_key => 'author_id'
  has_many    :projects, :through => :associated_projects
  has_many    :associated_projects
  has_many    :comments, :as => :commented, :dependent => :destroy  

  validates_presence_of :outgoing_code, :author_id, 
    :shipping_type, :shipping_to, :shipping_on
  validates_presence_of :files, :on => :create
  validates_format_of :outgoing_code, :with => /^\d+\-\d{2}(\/\d+)?$/,
    :message => I18n.t(:message_incorrect_format_outgoing_code)    
  validates_uniqueness_of :outgoing_code   
  validate :outgoing_code_incorrect_year
  validate :outgoing_code_in_series, :on => :create
  
  acts_as_attachable

  attr_accessor :project
  
  safe_attributes :outgoing_code, :incoming_code, :signer,
    :shipping_to, :shipping_type, :shipping_on, 
    :served_on, :recipient, :description  

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
  
  def previous_code
    PreviousCode.find(:last, :conditions => {
      :name => self.class.name.underscore, 
      :year => Time.now.strftime("%y")
    })
  end

  def attachments_visible?(user=User.current)
    user.allowed_to?(self.class.attachable_options[:view_permission], nil, :global => true)
  end

  def attachments_deletable?(user=User.current)
    user.allowed_to?(self.class.attachable_options[:delete_permission], nil, :global => true)
  end
  
  def editable_by?(usr)
    usr && usr.logged? && (usr.allowed_to?(:edit_outgoing_letters, nil, :global => true) || (self.author == usr && usr.allowed_to?(:edit_own_outgoing_letters, nil, :global => true))
    )
  end

  def destroyable_by?(usr)
    usr && usr.logged? && (usr.allowed_to?(:delete_outgoing_letters, nil, :global => true) || (self.author == usr && usr.allowed_to?(:delete_own_outgoing_letters, nil, :global => true))
    )
  end
end
