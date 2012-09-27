class SecretaryProjectsController < ApplicationController
  unloadable
  layout 'admin'

  before_filter :require_admin
  before_filter :find_secretary_project, :only => [:edit, :update, :destroy]
  before_filter :new_secretary_project, :only => [:new, :create]
  before_filter :find_users, :only => [:index, :new, :create, :edit, :update]
  before_filter :find_projects, :only => [:index, :new, :create, :edit, :update]
  
  def index
    @organizations = Organization.all(:order => :position)
  end
  
  def new
  end
  
  def create
    if @secretary_project.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end  
  end
  
  def edit
  end
  
  def update
    if @secretary_project.update_attributes(params[:secretary_project])
      flash[:notice] = l(:notice_successful_update)
      redirect_to :action => :index
    else
      render :action => :edit
    end    
  end
  
  def destroy
    if @secretary_project.destroy
      flash[:notice] = l(:notice_successful_delete)
    end
    redirect_to :action => 'index'          
  end
  
  private
    def find_secretary_project
      @secretary_project = SecretaryProject.find(params[:id])        
    end
    
    def new_secretary_project
      @secretary_project = SecretaryProject.new(params[:secretary_project])    
    end
    
    def find_users
      @users = User.active.all(:order => "lastname, firstname").map {|c| [c.name, c.id]}    
    end
    
    def find_projects
      @projects = Project.active.all(:order => "name").map {|c| [c.name, c.id]}      
    end
end
