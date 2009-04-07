class TicketsController < ApplicationController
  #auto_complete_for :street, :name
  skip_before_filter :verify_authenticity_token, :only => [:auto_complete_for_street_name]

  before_filter :check_type, :only => :create

  def auto_complete_for_street_name
    method = 'name'

    find_options = {
      :conditions => [ "LOWER(#{method}) LIKE ?", '%' + params[:ticket][:house][:street].downcase + '%' ],
      :order => "#{method} ASC",
      :limit => 10 }

    @items = Street.find(:all, find_options)

    render :inline => "<%= auto_complete_result @items, '#{method}' %>"
  end

  def new_request
    @ticket = ConnectionPossibilityRequest.new
  end

  def create
    klass  = Kernel.const_get(params[:ticket].delete(:type))
    @ticket = klass.new( params[:ticket] )
    @ticket.created_by = current_user
    if @ticket.valid?
      @ticket.save!
    else
      render :new_request
    end
  end

  def edit
  end

  def update
  end

  def mine
    @title = 'My tickets'
    @tickets = Ticket.all :conditions => {:created_by_id => current_user}
    render 'list'
  end

  def assigned_to_me
    @title = 'Tickets assigned to me'
    @tickets = Ticket.all :conditions => {:assignee_id => current_user}
    render 'list'
  end
  
  def all
    @title = 'All tickets'
    @tickets = Ticket.all
    render 'list'
  end

  private

  def check_type
    params[:ticket] && %w'ConnectionPossibilityRequest'.include?(params[:ticket][:type])
  end
end
