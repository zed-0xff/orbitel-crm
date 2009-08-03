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

  def new_tariff_change
    @ticket = TariffChange.new
    @ticket.house = House.new
    @ticket.date  = Date.today
    render :new
  end

  def create
    ticket_type = params[:ticket].delete(:type)
    klass  = ticket_type.blank? ? Ticket : Kernel.const_get(ticket_type)
    h1 = params[:ticket] || {}
    h2 = params[klass.to_s.underscore] || {}
    ticket_attrs= h1.merge(h2)
    logger.info ticket_attrs.inspect
    @ticket = klass.new( ticket_attrs )
    @ticket.created_by = current_user
    if @ticket.valid?
      @ticket.save!
      redirect_to ticket_path(@ticket)
      flash[:notice] = "Создана заявка № #{@ticket.id}"
    else
      if(
        @ticket.errors.on(:house_street) && !@ticket.house.street &&
        (!(st=ticket_attrs.try(:[], :house_attributes).try(:[], :street)).blank?)
      )
        # dirty hack
        s = @ticket.errors.on(:house_street)
        s[0..-1] = "^Улицы \"#{st}\" не существует"
      end
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

##########################################################
  
  def index
    @title = 'Текущие заявки'
    @tickets = prepare_tickets Ticket::COND_CURRENT, :order => "priority DESC, created_at"
    render 'list'
  end

  def all
    @title = 'Все заявки'
    @tickets = prepare_tickets
    render 'list'
  end

  def only_new
    @title = 'Новые заявки'
    @tickets = prepare_tickets Ticket::COND_NEW
    render 'list'
  end

  def closed
    @title = 'Закрытые заявки'
    @tickets = prepare_tickets :status => Ticket::ST_CLOSED
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

  def redirect
    @ticket.redirect!( Dept.find(params[:dept_id]), :user => current_user )
    flash[:notice] = "Заявка переадресована"
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

  def prepare_tickets conditions = nil, options = {}
    r = if params[:all_depts]
      Ticket
    else
      Ticket.for_user(current_user)
    end
    options[:conditions] ||= conditions
    options[:include] = [:house, :assignee, {:house => :street}]
    r.all options
  end
end
