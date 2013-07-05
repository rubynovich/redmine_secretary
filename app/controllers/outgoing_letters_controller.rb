class OutgoingLettersController < ApplicationController
  unloadable

  before_filter :find_object_by_id, :only => [:destroy, :edit, :show, :update]
  before_filter :find_organization, :only => [:index, :new]
  before_filter :find_current_project, :only => :index
  before_filter :get_related_projects, :only => [:edit, :update, :new, :create]

  helper :attachments
  include AttachmentsHelper
  helper :sort
  include SortHelper
  helper :outgoing_letters
  include OutgoingLettersHelper


  def index
    sort_init 'outgoing_code', 'desc'
#    sort_update %w(incoming_code outgoing_code answer_for signer shipping_to shipping_type shipping_on served_on recipient description created_on author_id)
    sort_update 'incoming_code' => "incoming_code",
                'outgoing_code' => ["SUBSTRING(outgoing_code,6,2)", 'outgoing_code'],
                'answer_for' => ["SUBSTRING(answer_for,6,2)", "answer_for"],
                'signer' => 'signer',
                'shipping_to' => 'shipping_to',
                'shipping_type' => 'shipping_type',
                'shipping_on' => 'shipping_on',
                'served_on' => 'served_on',
                'recipient' => 'recipient',
                'created_on' => 'created_on',
                'author_id' => 'author_id',
                'subject' => 'subject'

    scope = model_class.
      for_project(@project).
      this_organization(@organization.id).
      like_field(params[:incoming_code], :incoming_code).
      like_field(params[:outgoing_code], :outgoing_code).
      like_field(params[:answer_for], :answer_for).
      like_field(params[:signer], :signer).
      like_field(params[:shipping_to], :shipping_to).
      like_field(params[:recipient], :recipient).
      eql_field(params[:shipping_type], :shipping_type).
      eql_field(params[:shipping_on], :shipping_on).
      eql_field(params[:served_on], :served_on).
      eql_field(params[:created_on], :created_on).
      eql_field(params[:subject], :subject).
      time_period(params[:time_period_shipping_on], :shipping_on).
      time_period(params[:time_period_served_on], :served_on).
      time_period(params[:time_period_created_on], :created_on)

    @limit = per_page_option
    @count = scope.count
    @pages = Paginator.new self, @count, @limit, params[:page]
    @offset ||= @pages.current.offset
    @collection =  scope.find :all,
                              :order => sort_clause,
                              :limit  =>  @limit,
                              :offset =>  @offset
  end

  def new
    @object = model_class.new(
      :outgoing_code => next_code,
      :organization_id => @organization.id)
  end

  def update
    (render_403; return false) unless @object.editable_by?(User.current)
    @object.safe_attributes = params[model_name]
    @object.save_attachments(params[:attachments])
    @object.projects = Project.find(params[:projects].keys) rescue nil

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
    @object.projects = Project.find(params[:projects].keys) rescue nil
    @object.files = params[:attachments].keys if params[:attachments].present?

    if @object.save
      save_code(@object.outgoing_code)
      render_attachment_warning_if_needed(@object)
      flash[:notice] = l(:notice_successful_create)
      redirect_to( {:action => 'show', :id => @object} )
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

  def clean_previous_code
    PreviousCode.destroy_all(:name => model_name)
    redirect_to :action => 'new'
  end

  private
    def get_related_projects
      @related_projects = related_projects
    end

    def model_class
      OutgoingLetter
    end

    def model_name
      model_class.name.underscore
    end

    def find_object_by_id
      @object = model_class.find(params[:id])
    end

    def find_organization
      @organization = if params[:organization_id].present?
        Organization.find(params[:organization_id])
      end || Organization.default
    end

    def find_current_project
      @project = begin
        Project.find(params[:project_id])
      rescue
        nil
      end
    end

    def save_code(code)
      attributes = {
        :value => code[/\d+/],
        :year => code.split('-').last[/\d+/],
        :organization_id => @object.organization_id
      }
      if prev_code = previous_code(@object.organization_id)
        if (prev_code.value.to_i < attributes[:value].to_i)||(prev_code.year.to_i < attributes[:year].to_i)
          prev_code.update_attributes(attributes)
        end
      else
        PreviousCode.create(attributes.merge(:name => model_name))
      end
    end

    def next_code
      if prev_code = previous_code
        [prev_code.value.succ,Time.now.strftime("%y")].join('-')
      else
        Time.now.strftime("0001-%y")
      end
    end

    def previous_code(organization_id = find_organization.id)
      PreviousCode.find(:last, :conditions => {:name => model_name, :year => Time.now.strftime("%y"), :organization_id => organization_id})
    end
end
