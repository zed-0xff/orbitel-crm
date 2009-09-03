class TicketsController < ApplicationController
  include ERB::Util

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

    @ticket.title = params[:title] if params[:title] && !@ticket.title
    if !params[:ticket] && params[:customer_id]
      c = Customer.find_by_id(params[:customer_id].to_i)
      params[:ticket] = { :customer => c.name_with_address }
      @focus = 'ticket_title'
    end
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
    ticket_attrs = h1.deep_merge(h2)

    customer_name_addr = ticket_attrs.delete :customer

    if params[:quick_customer].to_i == 1
      if params[:ticket] && params[:ticket][:house_attributes]
        params[:ticket][:house_attributes].delete(:street)
      end
      ticket_attrs.delete 'flat'
      ticket_attrs.delete 'house_attributes'
      ticket_attrs.delete 'contact_name'
      ticket_attrs.delete 'contact_info'
      # customer quick-selected
      if !customer_name_addr.blank?
        ticket_attrs[:customer] = Customer.find_by_name_and_address(customer_name_addr)
      end
    else
      params[:ticket].try :delete, :customer
      params[klass.to_s.underscore].try :delete, :customer
    end

    # logger.info ticket_attrs.inspect

    @ticket = klass.new( ticket_attrs )

    if klass == Ticket && @ticket.customer && (t=Ticket.current.first( :conditions => {
      :customer_id => @ticket.customer.id,
      :title       => @ticket.title
    }))
      flash.now[:error_html] = "Такая заявка уже существует: <a href=\"#{ticket_path(t)}\">№#{t.id}: #{h(t.title)}</a>."
      @ticket.house ||= House.new
      render :new
      return
    end

    @ticket.created_by = current_user
    if @ticket.valid?
      @ticket.save!
      redirect_to ticket_path(@ticket)
      flash[:notice] = "Создана заявка № #{@ticket.id}"
    else
      if params[:quick_customer].to_i == 1
        @ticket.house = House.new
        if !customer_name_addr.blank? && !@ticket.customer
          @ticket.errors.add :customer, "^Абонент \"#{customer_name_addr}\" не найден"
        end
      end

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

  def change_priority
    if params[:priority]
      @ticket.change_priority!( params[:priority].to_i, :user => current_user )
      flash[:notice] = "Приоритет изменен"
    else
      flash[:notice] = "Ошибка изменения приоритета"
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

  def prepare_tickets conditions = nil, options = {}
    r = nil
    params.each do |k,v|
      case k.to_sym
        when :all_depts
          r ||= Ticket
        when :dept
          r ||= Ticket
          unless v.blank?
            r = r.for_dept(Dept.find(v.to_i))
          end
        when :created_at
          r ||= Ticket
          r = r.created_at(v.to_date)
        when :closed_at
          r ||= Ticket
          r = r.closed_at(v.to_date)
        when :reopened_at
          r ||= Ticket
          r = r.reopened_at(v.to_date)
        else
      end
    end

    # if none of above cases matched
    r ||= Ticket.for_user(current_user)
    
    options[:conditions] ||= conditions
    options[:include] = [:house, :assignee, {:house => :street}]
    r.all options
  end
end
