class SecretaryMembersController < ApplicationController
  unloadable
  layout 'admin'

  before_filter :require_admin
  before_filter :dates_for_index, :only => [:index, :edit]

  def index
    @secretary_member = SecretaryMember.new
    @method = :post
  end 
    
  def edit
    @secretary_member = SecretaryMember.find(params[:id])
    @method = :put
    render :index
  end
    
  def create
    @secretary_member = SecretaryMember.create(params[:secretary_member])
    redirect_to :controller => 'secretary_members', :action => 'index'
  end
  
  def update
    if secretary_member = SecretaryMember.find(params[:id])
      secretary_member.update_attributes(params[:secretary_member])
    end
    redirect_to :controller => 'secretary_members', :action => 'index'    
  end

  def destroy
    SecretaryMember.find(params[:id]).destroy if request.delete?
    @secretary_members = SecretaryMember.all
    redirect_to :controller => 'secretary_members', :action => 'index'
  end    
  
  private
  
    def dates_for_index
      @secretary_member_pages, @secretary_members = paginate :secretary_members, :per_page => 25, :order => "id"    
      @users = User.all(:order => "lastname, firstname")
      @organizations = Organization.all(:order => :position)    
    end
end
