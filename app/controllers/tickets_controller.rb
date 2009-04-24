class TicketsController < ApplicationController
  before_filter :check_type, :only => :create

  def new_request
    @ticket = ConnectionPossibilityRequest.new
    @ticket.house = House.new
  end

  def create
    klass  = Kernel.const_get(params[:ticket].delete(:type))
    logger.info params[:ticket].inspect
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
