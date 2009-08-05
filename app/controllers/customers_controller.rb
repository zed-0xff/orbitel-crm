class CustomersController < ApplicationController
  helper :calls, :tickets

  before_filter :prepare_customer

  skip_before_filter :verify_authenticity_token, :only => [:auto_complete]

  BILLING_INFO_CACHE_PERIOD = 4.hours
  ROUTER_INFO_CACHE_PERIOD  = 5.minutes

  def auto_complete
    method = 'name'

    find_options = {
      :conditions => [ "LOWER(#{method}) LIKE ?", '%' + find_customer(params).downcase + '%' ],
      :order => "#{method} ASC",
      :limit => 10 }

    @items = Customer.find(:all, find_options)

    render :text => '<ul class="customers-autocomplete">' + 
      @items.map{|item| "<li><div class='name'>#{item.name}</div><div class='addr'>(#{item.address})</div>" }.join + 
      '</ul>'
  end

  def index
    @title = 'Абоненты'
    
    conditions =
      if params[:filter].blank?
        nil
      else
        ["name LIKE ?", "%#{params[:filter]}%"]
      end

    @customers = Customer.paginate(
      :order      => 'name',
      :page       => params[:page],
      :per_page   => 50,
      :conditions => conditions,
      :include    => {:house => :street}
    )
  end

  def show
    @title   = @customer.name
    @calls   = @customer.calls
    @tickets = @customer.tickets.all(
      :conditions => Ticket::COND_CURRENT,
      :order      => "created_at DESC"
    )

    @binfo = read_fragment("customers/#{@customer.id}/billing_info")
    if @binfo && @binfo =~ /- TIMESTAMP:(\d+) -/ && ($1.to_i-Time.now.to_i).abs > BILLING_INFO_CACHE_PERIOD
      expire_fragment("customers/#{@customer.id}/billing_info")
      @binfo = nil
    end

    @rinfo = read_fragment("customers/#{@customer.id}/router_info")
    if @rinfo && @rinfo =~ /- TIMESTAMP:(\d+) -/ && ($1.to_i-Time.now.to_i).abs > ROUTER_INFO_CACHE_PERIOD
      expire_fragment("customers/#{@customer.id}/router_info")
      @rinfo = nil
    end
  end

  # show all customer tickets partial
  def all_tickets
    t0 = Time.now
    @tickets = @customer.tickets.all(
      :order      => "created_at DESC"
    )
    render :partial => 'tickets', :locals => {
      :title       => 'Все заявки',
      :link_title  => '[текущие]',
      :link_action => 'cur_tickets'
    }
    # very fast response breaks ajax indicators, so this hack
    sleep(0.05) if (Time.now - t0) < 0.05
  end

  # show current customer tickets partial
  def cur_tickets
    t0 = Time.now
    @tickets = @customer.tickets.all(
      :conditions => Ticket::COND_CURRENT,
      :order      => "created_at DESC"
    )
    render :partial => 'tickets', :locals => {
      :title       => 'Текущие заявки',
      :link_title  => '[все]',
      :link_action => 'all_tickets'
    }
    # very fast response breaks ajax indicators, so this hack
    sleep(0.05) if (Time.now - t0) < 0.05
  end

  KRUS_MAP = {
    :bal       => 'баланс',
    :bal_red   => nil,
    :tarif     => 'тариф',
    :tarif_red => nil,
    :name      => 'имя',
    :lic_schet => 'лиц.счет'
  }

  def billing_info
    expire_fragment("customers/#{@customer.id}/billing_info")
    @info = @customer.billing_info
    if v = @info[:traf_report]
      v.delete(:in_sat_day) if v[:in_sat] == v[:in_sat_day]
      v.delete :user_id
    end
    render :layout => false
  end

  def router_info
    expire_fragment("customers/#{@customer.id}/router_info")
    @info = @customer.router_info
    render :layout => false
  end

  private

  def prepare_customer
    @customer = Customer.find(params[:id].to_i) if params[:id]
    true
  end

  def find_customer h
    return h[:customer] if h[:customer] && h[:customer].is_a?(String)
    h.values.each do |v|
      r = v.is_a?(Hash) && find_customer(v)
      return r if r
    end
    nil
  end
end
