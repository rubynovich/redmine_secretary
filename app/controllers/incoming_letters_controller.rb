class IncomingLettersController < ApplicationController
  unloadable

  before_filter :find_object_by_id, only: [:destroy, :edit, :show, :update]
  before_filter :find_organization, only: [:index, :new, :create]
  before_filter :find_current_project, only: :index
  before_filter :get_related_projects, only: [:new, :create]
#  before_filter :required_view_permission, only: [:index, :show]

  helper :attachments
  include AttachmentsHelper
  helper :sort
  include SortHelper
  helper :incoming_letters
  include IncomingLettersHelper

  def index
    sort_init 'incoming_code', 'desc'
    #    sort_update %w(incoming_code outgoing_code answer_for signer shipping_from shipping_type shipping_on original_required recipient executor_id description created_on author_id)
    sort_update 'incoming_code' => ["SUBSTRING(incoming_code,6,2)", "incoming_code"],
    'outgoing_code' => 'outgoing_code',
    'answer_for' => ["SUBSTRING(answer_for,6,2)", "answer_for"],
    'signer' => 'signer',
    'shipping_from' => 'shipping_from',
    'shipping_type' => 'shipping_type',
    'shipping_on' => 'shipping_on',
    'original_required' => 'original_required',
    'recipient' => 'recipient',
    'executor_id' => 'executor_id',
    'created_on' => 'created_on',
    'author_id' => 'author_id',
    'subject' => 'subject'

    scope = model_class.
      for_project(@project).
      this_organization(@organization.id).
      like_executor(params[:executor]).
      like_field(params[:incoming_code], :incoming_code).
      like_field(params[:outgoing_code], :outgoing_code).
      like_field(params[:answer_for], :answer_for).
      like_field(params[:signer], :signer).
      like_field(params[:shipping_from], :shipping_from).
      like_field(params[:recipient], :recipient).
      eql_field(params[:shipping_type], :shipping_type).
      eql_field(params[:subject], :subject).
      eql_field(params[:original_required], :original_required).
      eql_field(params[:shipping_on], :shipping_on).
      eql_created_on(params[:created_on]).
      time_period(params[:time_period_shipping_on], :shipping_on).
      time_period(params[:time_period_created_on], :created_on)

    @limit = per_page_option
    @count = scope.count
    @pages = begin
      Paginator.new @count, @limit, params[:page]
    rescue
      Paginator.new self, @count, @limit, params[:page]
    end
    @offset ||= begin
      @pages.offset
    rescue
      @pages.current.offset
    end
    @collection = scope.
      order(sort_clause).
      limit(@limit).
      offset(@offset)
  end

  def new
    @object = model_class.new(
      incoming_code: next_code,
      organization_id: @organization.id
    )
  end

  def update
    (render_403; return false) unless @object.editable_by?(User.current)
#    @object.safe_attributes = params[model_name]
    @object.save_attachments(params[:attachments])
    @object.projects = params[:projects].keys if params[:projects].present?

    if @object.update_attributes(params[model_name])
      render_attachment_warning_if_needed(@object)
      flash[:notice] = l(:notice_successful_update)
      redirect_to action: 'index'
    else
      render action: 'edit'
    end
  end

  def create
    @object = model_class.new(params[model_name])
#    @object.safe_attributes = params[model_name]
    @object.save_attachments(params[:attachments])
    @object.projects = params[:projects].keys if params[:projects].present?
    @object.files = params[:attachments].keys if params[:attachments].present?

    if @object.save
      save_code(@object.incoming_code)
      issues = @object.create_issues.map{ |issue| "##{issue.id}" }.join(", ")
      #add_to_description(issues)
      render_attachment_warning_if_needed(@object)
      flash[:notice] = l(:notice_successful_create)
      redirect_to action: 'show', id: @object
    else
      render action: 'new'
    end
  end

  def destroy
    (render_403; return false) unless @object.destroyable_by?(User.current)
    @object.destroy
    flash[:notice] = l(:notice_successful_delete)
    redirect_to action: 'index'
  end

  def clean_previous_code
    PreviousCode.destroy_all(name: model_name)
    redirect_to action: 'new'
  end

  def autocomplete_for_signer
    autocomplete_for_field(:signer)
  end

  def autocomplete_for_recipient
    autocomplete_for_field(:recipient)
  end

  def autocomplete_for_shipping_from
    autocomplete_for_field(:shipping_from)
  end

private

  def get_related_projects
    @related_projects = related_projects
  end

  def model_class
    IncomingLetter
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
      value: code[/\d+/],
      year: code.split('-').last[/\d+/],
      organization_id: @object.organization_id
    }
    if prev_code = previous_code(@object.organization_id)
      if prev_code.value.to_i < attributes[:value].to_i
        prev_code.update_attributes(attributes)
      end
    else
      PreviousCode.create(attributes.merge(name: model_name))
    end
  end

  def next_code
    if prev_code = previous_code
      [prev_code.value.succ, Time.now.strftime("%y")].join('-')
    else
      Time.now.strftime("0001-%y")
    end
  end

  def previous_code(organization_id = find_organization.id)
    PreviousCode.where(
      name: model_name,
      year: Time.now.strftime("%y"),
      organization_id: organization_id
    ).last
  end

  def add_to_description(str)
    @object.update_attribute :description, [@object.description, str].join("\n\n")
  end

  def autocomplete_for_field(field)
    completions = IncomingLetter.where("#{field} LIKE ?", "%#{params[:term]}%").
      uniq(field).
      pluck(field).
      map{ |value| {id: value, label: value, value: value} }
    render text: completions.to_json, layout: false
  end

#  def required_view_permission

#  end
end
