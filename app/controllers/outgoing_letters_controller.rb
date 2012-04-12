class OutgoingLettersController < ApplicationController
  unloadable

  def index
    @collection = model_class.all
  end

  def new
    @object = model_class.new
    @object.author = User.current
    if request.post?
      @object.save_attachments(params[:attachments])
      if @object.save
        render_attachment_warning_if_needed(@object)
        redirect_to :action => 'show', :id => @object
      end
    end    
  end
  
  def show
    @object = model_class.find(params[:id])
  end

  def edit
    @object = model_class.find(params[:id])
  end

  def update
    @object = model_class.find(params[:id])
    if @object.update_attribute(params[model_name])
      flash[:notice] = l(:notice_successful_update)
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end      
  end

  def create
    model_class.create(params[model_name])
  end

  def destroy
    @object = model_class.find(params[:id])
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
end
