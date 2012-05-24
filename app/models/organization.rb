class Organization < ActiveRecord::Base
  unloadable

  validates_presence_of :title
  
  def update_default
    self.class.update_all("is_default=#{connection.quoted_false}", ['id <> ?', id]) if self.is_default?
  end
  
  def self.default
    find(:first, :conditions =>["is_default=?", true])
  end
  
  def to_s
    title
  end
end
