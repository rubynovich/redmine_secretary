class OutgoingLettersController < ApplicationController
  unloadable

  before_filter :find_object_by_id, :only => [:destroy, :edit, :show, :update]
   
  helper :attachments
   
  def index
    @collection = model_class.all
  end

  def new
    @object = model_class.new
    if request.post?
      @object.save_attachments(params[:attachments])
      if @object.save
        render_attachment_warning_if_needed(@object)
        redirect_to :action => 'show', :id => @object
      end
    end    
  end
  
  def show
  end

  def edit
  end

  def update
    @object.safe_attributes = params[model_name]
    @object.save_attachments(params[:attachments])    
    if @object.update_attribute(params[model_name])
      flash[:notice] = l(:notice_successful_update)
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end      
  end

  def create
    @object = model_class.new(:author => User.current)
    @object.safe_attributes = params[model_name]
    @object.save_attachments(params[:attachments])

    if @object.save
      render_attachment_warning_if_needed(@object)
      flash[:notice] = l(:notice_successful_create)
      redirect_to( params[:continue] ? {:action => 'new'} :                     {:action => 'show', :id => @object} )
    else
      render :action => 'new'
    end    
  end

  def destroy
    (render_403; return false) unless @object.destroyable_by?(User.current)
    @object.destroy
    flash[:notice] = l(:notice_successful_delete)
    redirect_to :action => 'index'
  end
  
  private
    def model_class
      OutgoingLetter
    end
    
    def model_name
      :outgoing_letter
    end  
    
    def find_object_by_id
      @object = model_class.find(params[:id])
    end
end
