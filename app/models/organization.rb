class Organization < ActiveRecord::Base
  unloadable
  acts_as_list

  after_save     :update_default
  before_destroy :check_integrity
  
  validates_presence_of :title
  validates_uniqueness_of :title
  
  has_many :secretary_members
  has_many :secretary_projects
  
  def <=>(status)
    position <=> status.position
  end
  
  def update_default
    self.class.update_all("is_default=#{connection.quoted_false}", ['id <> ?', id]) if self.is_default?
  end
  
  def self.default
    find(:first, :conditions =>["is_default=?", true])
  end
  
  def to_s
    title
  end
  
  private
    def check_integrity
      raise "Can't delete organization" if [IncomingLetter, OutgoingLetter, SecretaryMember, SecretaryProject].any?{ |c| c.find(:first, :conditions => ["organization_id=?", self.id])}
    end
end
