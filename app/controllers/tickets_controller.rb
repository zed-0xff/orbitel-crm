class TicketsController < ApplicationController
  before_filter :check_type, :only => :create
  before_filter :prepare_ticket

  def new_request
    @ticket = ConnectionPossibilityRequest.new
    @ticket.house = House.new
    render :new
  end

  def new
    @ticket = Ticket.new
    @ticket.house = House.new
  end

  def create
    ticket_type = params[:ticket].delete(:type)
    klass  = ticket_type.blank? ? Ticket : Kernel.const_get(ticket_type)
    logger.info params[:ticket].inspect
    @ticket = klass.new( params[:ticket] )
    @ticket.created_by = current_user
    if @ticket.valid?
      @ticket.save!
    else
      render :new
    end
  end

  def edit
  end

  def update
  end

  def show
    @title = "Заявка №#{@ticket.id} - #{@ticket.title}"
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
  
  def index
    @title = 'Текущие заявки'
    @tickets = Ticket.all(
      :conditions => Ticket::COND_CURRENT,
      :order => "priority DESC, created_at"
    )
    render 'list'
  end

  def all
    @title = 'Все заявки'
    @tickets = Ticket.all
    render 'list'
  end

  def only_new
    @title = 'Новые заявки'
    @tickets = Ticket.all :conditions => Ticket::COND_NEW
    render 'list'
  end

##########################################################

  def add_comment
    text = params[:text].to_s.strip
    unless text.blank?
      @ticket.history.create!(
        :user    => current_user,
        :comment => text
      )
      flash[:notice] = "Комментарий добавлен"
    end
    redirect_to ticket_path(@ticket)
  end

##########################################################

  def accept
    @ticket.change_status! Ticket::ST_ACCEPTED, 
      :user => current_user, :assign => true
    flash[:notice] = "Заявка принята в обработку"
    redirect_to ticket_path(@ticket)
  end

  def close
    @ticket.change_status! Ticket::ST_CLOSED, 
      :user => current_user, :assign => false, :comment => params[:comment]
    flash[:notice] = "Заявка закрыта"
    redirect_to ticket_path(@ticket)
  end

  def reopen
    @ticket.change_status! Ticket::ST_REOPENED, 
      :user => current_user, :assign => false
    flash[:notice] = "Заявка переоткрыта"
    redirect_to ticket_path(@ticket)
  end

##########################################################

  private

  def check_type
    params[:ticket] && %w'ConnectionPossibilityRequest'.include?(params[:ticket][:type])
  end

  def prepare_ticket
    if params[:id]
      @ticket = Ticket.find params[:id].to_i
    end
    true
  end

end
