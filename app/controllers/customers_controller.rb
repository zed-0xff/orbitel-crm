class CustomersController < ApplicationController
  include ActionView::Helpers::TextHelper # for 'cycle' method
  include ActionView::Helpers::NumberHelper   

  helper :calls, :tickets

  before_filter :prepare_customer

  skip_before_filter :verify_authenticity_token, :only => [:auto_complete]

  verify :method => :post, :only => %w'billing_toggle_inet'

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

  def router_info
    expire_fragment("customers/#{@customer.id}/router_info")
    @info = @customer.router_info
    render :layout => false
  end

  def traf
    ti = Krus.user_traf_info( @customer.external_id )
    @title      = @customer.name
    @traf       = ActiveSupport::OrderedHash.new
    ti[:traf].keys.sort.each do |key|
      @traf[key] = ti[:traf][key]
    end
    if ti[:bandwidth]
      @max_day_traf    = ti[:bandwidth] * 1024 / 8 * 3600 * 24
      @max_day_traf_mb = @max_day_traf / 1.megabyte
    end
    @traf_types = @traf.values.map{ |v| v.keys }.flatten.uniq.sort_by{ |v| v.to_s }

    colors = %w'#9933CC #99CC33 #CC9933 #0000ff #00ff00 #ffff00'

    @chart = {
      "y_axis"   => {
        "max"   => 20,
        "labels" => { "text" => " #val# Mb" }
#        , "labels" => [
#          { 'y' => 2048, 'text' => 'zzzz', 'grid-colour' => '#ff0000' }
#        ]}
      },
      "x_axis"   => {
        "min" => @traf.keys.first.to_time.to_i,
        "max" => @traf.keys.last.to_time.to_i,
        "steps" => 86400,
        "labels" => {
          "text" => "#date:d.m#",
          "steps" => 86400,
          "visible-steps" => 2,
        }
      },
      "elements" => [],
      "num_decimals" => 0
    }

    @traf_types.each do |traf_type|
      traf_values = []
      @traf.each do |dt,day_traf|
        next unless (amount = day_traf[traf_type])
        v = amount / 1.megabyte
        next if v <= 0
        traf_values << { 
          'x'   => dt.to_time.to_i, 
          'y'   => v,
          'tip' => "#{traf_type}:<br>#{number_to_human_size(amount)}"
        }
      end

      if @max_day_traf_mb && !traf_type.to_s['local']
        traf_values.each do |h|
          if h['y'] >= @max_day_traf_mb
            h['type']     = 'solid-dot'
            h['dot-size'] = 6
            h['hollow']   = false
            h['colour']   = '#ff0000'
          end
        end
      end

      chart_el = {
        "font-size" => 10,
        "text"      => traf_type.to_s,
        "type"      => "line",
        "colour"    => cycle(*colors),
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
      max_value = el['values'].map{ |v| v['y'].to_i }.max.to_i
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

    @chart['y_axis']['labels']['labels'] << { 'y' => 0,    'text' => '0 GB' }
    @chart['y_axis']['labels']['labels'] << { 'y' => 1024, 'text' => '1 GB' }

    # maximal Y value Y-axis label
    @chart['y_axis']['labels']['labels'] << {
      'y'           => @chart['y_axis']['max'],
      'text'        => " #{number_to_human_size(@chart['y_axis']['max'] * 1.megabyte)}"
    }
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
