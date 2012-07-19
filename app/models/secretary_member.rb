class SecretaryMember < ActiveRecord::Base
  unloadable
  
  belongs_to :user
  belongs_to :organization
  
  validates_uniqueness_of :user_id, :scope => :organization_id
  validates_presence_of :user_id, :organization_id  
  
#  def edit_incoming?(organization_id = params[:organization_id])
#    if secretary_member = find(:first, :conditions => {:user_id => User.current.id, :organization_id => organization_id})
#      secretary_member.incoming_edit
#    end
#  end

#  def new_incoming?(organization_id = params[:organization_id])
#    if secretary_member = find(:first, :conditions => {:user_id => User.current.id, :organization_id => organization_id})
#      secretary_member.incoming_new
#    end
#  end

#  def edit_outgoing?(organization_id = params[:organization_id])
#    if secretary_member = find(:first, :conditions => {:user_id => User.current.id, :organization_id => organization_id})
#      secretary_member.outgoing_edit
#    end
#  end

#  def new_outgoing?(organization_id = params[:organization_id])
#    if secretary_member = find(:first, :conditions => {:user_id => User.current.id, :organization_id => organization_id})
#      secretary_member.outgoing_new
#    end
#  end
  
end
