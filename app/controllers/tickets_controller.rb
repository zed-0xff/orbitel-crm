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

    respond_to do |format|
      format.html
      format.yaml { render :text => { 'authenticity_token' => form_authenticity_token }.to_yaml }
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
    ticket_attrs = deep_merge(h1, h2)

    allow_doubles      = ticket_attrs.delete :allow_doubles
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

    ok = false

    if klass == Ticket &&
      @ticket.customer &&
      !allow_doubles   &&
      (t=Ticket.current.first( :conditions => {
        :customer_id => @ticket.customer.id,
        :title       => @ticket.title
    }))
      flash.now[:error_html] = "Такая заявка уже существует: <a href=\"#{ticket_path(t)}\">№#{t.id}: #{h(t.title)}</a>."
      @ticket.house ||= House.new
#      render :new
#      return
    else
      @ticket.created_by = current_user
      if @ticket.valid?
        @ticket.save!
#        redirect_to ticket_path(@ticket)
        flash[:notice] = "Создана заявка № #{@ticket.id}"
        ok = true
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
      end
    end

    respond_to do |format|
      format.html { ok ? redirect_to(ticket_path(@ticket)) : render(:new) }
      format.yaml {
        r = {
          'ticket'    => @ticket.attributes.reject{ |k,v| v.blank? },
          'ticket_id' => @ticket.id,
          'ok'        => ok
        }
        r['errors'] = @ticket.errors.full_messages unless ok
        render :text => r.ya2yaml
      }
    end
  end

  # to be called from API
  def find
    sanitizers = {
      :type            => Proc.new{ |x| x.to_s },
      :status          => Proc.new{ |st| st.is_a?(Array) ? st.map(&:to_i) : st.to_i },
      :customer_id     => Proc.new{ |x| x.to_i },
      :customer_ext_id => Proc.new{ |x| x.to_i }
    }
    c = {}
    params.each do |k,v|
      k = k.to_sym
      c[k] = sanitizers[k].call(v) if sanitizers[k]
    end
    if c.key?(:customer_ext_id)
      if cust = Customer.find_by_external_id(c[:customer_ext_id])
        c.delete :customer_ext_id
        c[:customer_id] = cust.id
      else
        c = nil # disallow Ticket.first call
        r['error'] = "Cannot find customer by ext_id = #{c[:customer_ext_id]}"
      end
    end

    r = {}; @ticket = nil

    @ticket = Ticket.first(
      :conditions => c,
      :order => "created_at DESC"
    ) if c

    respond_to do |format|
      format.yaml {
        r['ticket'] = @ticket && @ticket.attributes.reject{ |k,v| v.blank? }
        render :text => r.ya2yaml
      }
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
    if params[:dept_id]
      @ticket.redirect!( Dept.find(params[:dept_id].to_i), :user => current_user )
      flash[:notice] = "Заявка переадресована"
    elsif params[:user_id]
      @ticket.redirect!( User.find(params[:user_id].to_i), :user => current_user )
      flash[:notice] = "Заявка переадресована"
    else
      flash[:error] = "Недопустимая комбинация параметров!"
    end
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

  # подготовка дерева узлов для AJAX тычки "зависание узла"
  def nodes
    @nodes = []
    node = @ticket.customer.node
    while node
      @nodes.unshift node
      node = node.parent
    end
    sp = ''
    @nodes_for_select = []
    @nodes.each do |node|
      t = (sp.blank? ? "" : "#{sp}┗&nbsp;") << node.name
      @nodes_for_select << [t.html_safe, node.id]
      sp += "&nbsp;&nbsp;"
    end
    render :layout => false
  end

  def node_hang
    @node = Node.find(params[:node_id].to_i)
    ticket = nil
    if ticket = NodeHangTicket.current.find_by_node_id(@node.id)
    else
      ticket = NodeHangTicket.create! :node => @node, :created_by => current_user
    end
    ticket.child_tickets << @ticket
    redirect_to ticket
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
    if params[:close_childs]
      @ticket.child_tickets.each do |t|
        if t.status != Ticket::ST_CLOSED
          t.change_status! Ticket::ST_CLOSED,
            :user => current_user, :assign => false, :comment => params[:comment]
        end
      end
    end
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

  # this method is here because Rails cannot merge two HashWithIndifferentAccess'es
  def deep_merge h1,h2
    r = h1.is_a?(HashWithIndifferentAccess) ? HashWithIndifferentAccess.new : Hash.new
    h1.each do |k1,v1|
      if v1.is_a?(Hash) && h2[k1].is_a?(Hash)
        r[k1] = deep_merge(h1[k1], h2[k1])
      else
        r[k1] = v1
      end
    end
    h2.each do |k2,v2|
      unless h1.key?(k2)
        r[k2] = v2
      end
    end
    r
  end

#  def rescue_action(exception)
#    respond_to do |format|
#      format.html {
#        super(exception)
#      }
#      format.yaml {
#        log_error exception
#        render :text => {
#          'ok'    => false,
#          'error' => exception.to_s
#        }.ya2yaml
#      }
#    end
#  end
end
