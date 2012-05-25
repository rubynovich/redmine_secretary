class OrganizationsController < ApplicationController
  unloadable
  layout 'admin'

  before_filter :require_admin

#  helper :custom_fields

  # GET /organizations
  def index
    @organization_pages, @organizations = paginate :organizations, :per_page => 25, :order => "position"
    render :action => "index", :layout => false if request.xhr?
  end

  # GET /organizations/new
  def new
    @organization = Organization.new
  end
  
  # POST /organizations
  def create
    @organization = Organization.new(params[:organization])
    if request.post? && @organization.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  # GET /organizations/1/edit
  def edit
    @organization = Organization.find(params[:id])
  end

  # POST /organizations
  def create
    @organization = Organization.new(params[:organization])
    if request.post? && @organization.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  # PUT /organizations/1
  def update
    @organization = Organization.find(params[:id])

    respond_to do |format|
      if @organization.update_attributes(params[:organization])
        flash[:notice] = l(:notice_successful_update)
        format.html { redirect_to(organizations_path) }
      else
        format.html { render :action => "edit" }
      end
    end
  end
  
  # DELETE /organizations/1
  def destroy
    Organization.find(params[:id]).destroy
    redirect_to :action => 'index'
  rescue
    flash[:error] = l(:error_unable_delete_organization)
    redirect_to :action => 'index'
  end  
end
