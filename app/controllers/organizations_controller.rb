class OrganizationsController < ApplicationController
  layout 'admin'

  before_filter :require_admin

#  helper :custom_fields

  # GET /organizations
  def index
    @organizations = Organization.find(:all, :order => 'title')
  end

  # GET /organizations/1
  def show
    @organization = Organization.find(params[:id])
  end

  # GET /organizations/new
  def new
    @organizations = Organization.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /organizations/1/edit
  def edit
    @organization = Organization.find(params[:id], :include => :projects)
  end

  # POST /organizations
  def create
    @organization = Organization.new(params[:group])

    respond_to do |format|
      if @organization.save
        format.html {
          flash[:notice] = l(:notice_successful_create)
          redirect_to(params[:continue] ? new_organization_path : organizations_path)
        }
      else
        format.html { render :action => "new" }
      end
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

  # DELETE /groups/1
  def destroy
    @organization = Organization.find(params[:id])
    @organization.destroy

    respond_to do |format|
      format.html { redirect_to(organizations_url) }
    end
  end
end
