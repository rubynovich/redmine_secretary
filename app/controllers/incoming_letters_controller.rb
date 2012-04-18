class IncomingLettersController < ApplicationController
  unloadable

  before_filter :find_object_by_id, :only => [:destroy, :edit, :show, :update]
   
  helper :attachments
  include AttachmentsHelper  
  helper :sort
  include SortHelper
   
  def index
    sort_init 'incoming_code', 'asc'
    sort_update %w(incoming_code outgoing_code signer shipping_from shipping_type shipping_on original_required recipient executor_id description created_on author_id)

    @collection = model_class.find :all, :order => sort_clause

    respond_to do |format|
      format.html {
        render :layout => !request.xhr?
      }
    end	    
  end

  def new
    @object = model_class.new(:incoming_code => next_code)
    @related_projects = Member.find(:all, :conditions => {:user_id => User.current.id}).map{ |m| m.project }

#    if request.post?
#      @object.save_attachments(params[:attachments])
#      if @object.save
#        render_attachment_warning_if_needed(@object)
#        redirect_to :action => 'show', :id => @object
#      end
#    end    
  end
  
  def show
  end

  def edit
  end

  def update
    (render_403; return false) unless @object.editable_by?(User.current)
    @object.safe_attributes = params[model_name]
    @object.save_attachments(params[:attachments])    
    if @object.update_attributes(params[model_name])
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
      save_code(@object.incoming_code)
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
      IncomingLetter
    end
    
    def model_name
      :incoming_letter
    end  
    
    def find_object_by_id
      @object = model_class.find(params[:id])
    end
    
    def save_code(code)
      attributes = {
        :value => code[/\d+/],
        :year => code.split('-').last[/\d+/]
      }      
      if prev_code = PreviousCode.find_by_name(model_name)
        if (prev_code.value.to_i < attributes[:value].to_i)||(prev_code.year.to_i < attributes[:year].to_i)
          prev_code.update_attributes(attributes)
        end
      else
        PreviousCode.create(attributes.merge(:name => model_name))
      end
    end
    
    def next_code
      year = Time.now.strftime("%y")
      if (prev_code = PreviousCode.find_by_name(model_name))&&(prev_code.year.to_i == year.to_i)
        [prev_code.value.succ,year].join('-')
      else
        Time.now.strftime("0001-%y")
      end
    end    
end
