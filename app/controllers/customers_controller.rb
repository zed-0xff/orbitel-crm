class CustomersController < ApplicationController
  include ActionView::Helpers::TextHelper # for 'cycle' method
  include ActionView::Helpers::NumberHelper   
  include ApplicationHelper
  include CustomersHelper # hmm?

  helper :calls, :tickets

  before_filter :prepare_customer
  before_filter :check_can_manage, :only => %w'edit update'

  skip_before_filter :verify_authenticity_token, :only => [:auto_complete]

  verify :method => :post, :only => %w'billing_toggle_inet billing_correct_balance delete_phone add_phone'

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
    Rails.cache.delete "customer.#{@customer.id}.tariff"
    @info ||= @customer.billing_info
    if v = @info[:traf_report]
      v.delete(:in_sat_day) if v[:in_sat] == v[:in_sat_day]
      v.delete :user_id
    end
    render :action => 'billing_info', :layout => false
  end

  def billing_toggle_inet
    @info = @customer.billing_toggle_inet(params[:state] == 'on')
    billing_info
  end

  def billing_correct_balance
    @info = @customer.billing_correct_balance(params[:amount], params[:comment])
    billing_info
  end

  def router_info
    expire_fragment("customers/#{@customer.id}/router_info")
    @info = @customer.router_info
    render :layout => false
  end

  def traf
    @traf_dt = Date.today
    args = {}
    if params[:pos]
      @traf_dt += params[:pos].to_i.months
      args[:month] = @traf_dt.month
      args[:year]  = @traf_dt.year
    end

    dt_start = Date.civil(@traf_dt.year, @traf_dt.month)
    dt_end   = Date.civil(@traf_dt.year, @traf_dt.month, -1)

    ti = Krus.user_traf_info( @customer.external_id, args )
    @traf       = ActiveSupport::OrderedHash.new
    return if ti[:traf].blank?

#    (ti[:traf].keys.min..ti[:traf].keys.max).each do |key|
    (dt_start..dt_end).each do |dt|
      @traf[dt] = ti[:traf][dt]
    end
    if ti[:bandwidth]
      @max_day_traf    = ti[:bandwidth] * 1024 / 8 * 3600 * 24
      @max_day_traf_mb = @max_day_traf / 1.megabyte
    end
    @traf_types = @traf.values.map{ |v| v.try(:keys) }.flatten.compact.uniq.sort_by{ |v| v.to_s }

    colors = %w'#0000ff #ffff00 #99CC33 #CC9933 #00ff00 #ffff00'

    @chart = {
      "title" => {
        'text' => "Интернет-трафик за #{month_name(@traf_dt.month)} #{@traf_dt.year}"
      },
      "y_axis"   => {
        "max"   => 20,
        "labels" => { "text" => " #val# Mb" }
#        , "labels" => [
#          { 'y' => 2048, 'text' => 'zzzz', 'grid-colour' => '#ff0000' }
#        ]}
      },
      "x_axis"   => {
#        "min" => @traf.keys.first.to_time.to_i,
#        "max" => @traf.keys.last.to_time.to_i,
        "steps" => 2,
        "labels" => {
          "labels" => @traf.keys.map{ |dt| dt.strftime('%d.%m') },
          "steps"  => 2
        }
      },
      "elements" => [],
      "num_decimals" => 0,
      "bg_colour" => '#eeeeee'
    }

    @traf_types.each do |traf_type|
      tts = traf_type.to_s
      next unless tts['inet']
      is_local = tts['local']
      traf_values = []
      @traf.each do |dt,day_traf|
        amount = day_traf ? day_traf[traf_type] : nil
        v = amount.to_i / 1.megabyte
        if v <= 0
          traf_values << nil
        else
          traf_values << { 
  #          'x'   => dt.to_time.to_i, 
            (is_local ? 'y' : 'top')   => v,
            'tip' => "#{dt} (#{traf_type})<br>#{number_to_human_size(amount)}"
          }
        end
      end

      if @max_day_traf_mb && !is_local
        traf_values.each do |h|
          if h && h.key?('top') && h['top'] >= @max_day_traf_mb
#            h['type']     = 'solid-dot'
#            h['dot-size'] = 6
#            h['hollow']   = false
            h['colour']   = '#ff0000'
          end
        end
      end

      chart_el = {
        "font-size" => 10,
        "text"      => traf_type.to_s,
        "type"      => "bar_filled",
        "colour"    => cycle(*colors),
        "alpha"     => 1.0,
        "values"    => traf_values,
        "tip"       => "!!!<br>#val#<br>#x_label#",
        "width"     => (traf_type.to_s['local'] ? 1 : 3),
        "dot-style" => {
          'type'      => 'hollow-dot',
          'dot-size'  => 5,
          'halo-size' => 0
        }
      }
      @chart['elements'] << chart_el
    end

    # determine Y axis maximum
    @chart['elements'].each do |el|
      max_value = el['values'].map{ |v| v ? v['top'].to_i : 0 }.max.to_i
      @chart['y_axis']['max'] = max_value if max_value > @chart['y_axis']['max']
    end

    if @max_day_traf_mb && @chart['y_axis']['max'] > @max_day_traf_mb
      @chart['y_axis']['labels']['labels'] ||= []
      @chart['y_axis']['labels']['labels'] << {
        'y'           => @max_day_traf_mb,
        'text'        => " #{number_to_human_size(@max_day_traf)}",
        'grid-colour' => '#ff0000',
        'colour'      => '#ff0000'
      }
    end

    @chart['y_axis']['max'] = ((@chart['y_axis']['max'] / 1024) + 1) * 1024
    @chart['y_axis']['labels']['labels'] ||= []

    a0 = (0...(@chart['y_axis']['max']/1024)).to_a
    a = a0; gsize = 1
    while a.size > 10
      gsize += 1
      a = a0.in_groups_of(gsize).map{|x| x.first}.compact
    end
    a.each do |v|
      @chart['y_axis']['labels']['labels'] << { 'y' => v*1024, 'text' => "#{v} GB" }
    end

    # maximal Y value Y-axis label
    @chart['y_axis']['labels']['labels'] << {
      'y'           => @chart['y_axis']['max'],
      'text'        => " #{number_to_human_size(@chart['y_axis']['max'] * 1.megabyte)}"
    }
  end

  def change_karma
    value = params[:value].to_i
    raise "invalid value" if value.abs != 1

    unless allow_karma_change_of(@customer)
      render :update do |page|
        page << 'alert("Вы сегодня уже изменяли карму этому пользователю")'
      end
      return
    end

    @customer.karma = @customer.karma.to_i + value
    @customer.save!

    # allow changing Customer's karma by each User only once per 24h
    cache_key = "customer.#{@customer.id}.karma-changed-by.#{current_user.id}"
    Rails.cache.write cache_key, true, :expires_in => 24.hours

    render :update do |page|
      page.replace_html 'karma', karma_of(@customer)
    end
  end

  def update
    @customer.update_attributes(params[:customer])
    if (t=params[:new_phone].to_s.gsub(/[^0-9]/,'')).size >= 5
      @customer.phones.add t
    end
    redirect_to customer_path(@customer)
  end

  # called from AJAX
  def delete_phone
    @phone = @customer.phones.find(params[:phone_id].to_i)
    @phone.destroy
    render :partial => 'phones'
  end

  # called from AJAX
  def add_phone
    if (t=params[:new_phone].to_s.gsub(/[^0-9]/,'')).size >= 5
      @customer.phones.add t
      params[:new_phone] = nil
    else
      @new_phone_is_invalid = true
    end
    render :partial => 'phones'
  end

  # to be called from API
  # сначала ищем кастомера по external_id, если такого нет - то создаем
  # в любом случае возвращаем id созданного либо найденного 
  def find_or_create
    r = {}
    if !params[:customer]
      r['error'] = "no 'customer' in params"
    elsif !params[:customer][:external_id]
      r['error'] = "no 'customer[external_id]' in params"
    elsif params[:customer][:external_id].to_s !~ /^\d+$/
      r['error'] = "invalid external_id"
    else
      if customer = Customer.find_by_external_id(params[:customer][:external_id].to_i)
        r['customer_id'] = customer.id
      else
        phones = params[:customer].delete(:phones)
        customer = Customer.new( params[:customer] )
        if customer.valid?
          customer.save!
          r['customer_id'] = customer.id
          unless phones.blank?
            customer.phones.add phones
            # сохраняем без кидания эксепшенов если невозможно сохранить
            # т.к. есть вероятность совпадения номеров телефонов с другими кастомерами
            customer.save
          end
        else
          r['error'] = "validation failed"
          r['errors'] = customer.errors.full_messages
        end
      end
    end
    render :text => r.to_yaml
  end

  private

  def check_can_manage
    current_user.can_manage?:customers
  end

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
