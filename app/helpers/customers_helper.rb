module CustomersHelper
  TRAF_TYPES = {
    :in_sat   => 'входящий',
    :inet_out => 'исходящий',
    :local    => 'локальный'
  }

  def traf_type type
    TRAF_TYPES[type] || type
  end

  def traf_amount type
    r = number_to_human_size(@info[:traf_report][type])
    if @info[:bandwidth]
      r = "<div class='traf-amount'>#{r}</div>"
      if [:inet_out, :in_sat].include?(type)
        # max traffic amount from start of month to current day
        max_amount = @info[:bandwidth] * 1024 / 8 * 3600 * 24 * Date.today.day
        percent    = 100 * @info[:traf_report][type] / max_amount
        klass      = 'traf-amount-percent' + ((percent >= 100) ? ' red' : '')
        r += "<div title='Процент от максимально возможного на текущую дату' class='#{klass}'>(#{percent.to_s.rjust(2)}%)</div>"
      end
    end
    r
  end

  def prev_customer_link opts = {}
    customer_link :prev, opts
  end

  def next_customer_link opts = {}
    customer_link :next, opts
  end

  def karma_of cust
    r = '&nbsp;'
    r+= link_to_remote('-',
                        {
                          :url   => {:action => 'change_karma', :id => cust, :value => -1}
                        },
                        :style => 'color:red; text-decoration:none',
                        :title => 'понизить карму'
                      ) if allow_karma_change_of(cust)
    r+= '<strong>&nbsp;'
    r+=
      if cust.karma.to_i > 0
        '<span style="color:green">'
      elsif cust.karma.to_i < 0
        '<span style="color:red">'
      else
        '<span style="color:gray">'
      end
    r+= cust.karma.to_i.to_s
    r+= "</span>&nbsp;</strong>"
    r+= link_to_remote('+',
                        {
                          :url   => {:action => 'change_karma', :id => cust, :value => +1}
                        },
                        :style => 'color:green; text-decoration:none',
                        :title => 'повысить карму'
                      ) if allow_karma_change_of(cust)
    r
  end

  def allow_karma_change_of cust
    cache_key = "customer.#{cust.id}.karma-changed-by.#{current_user.id}"
    !Rails.cache.read(cache_key)
  end

  private

  def customer_link dir, opts = {}
    case dir
      when :prev
        cmp  = '<'
        text = '&larr;'
      when :next
        cmp  = '>'
        text = '&rarr;'
      else
        raise "Invalid direction: #{dir.inspect}"
    end

    cust =
      if params[:from] == 'house'
        cust_from_house dir
      else
        Customer.first(
          :conditions => ["id #{cmp} ?", @customer.id],
          :order => ( dir == :prev ? "id DESC" : "id" )
        )
      end

    if cust
      opts[:from] = params[:from] if params[:from]
      path = opts[:action] ? opts.merge(:controller => 'customers', :id => cust) : customer_path(cust, opts)
      link_to "<b>ctrl</b>#{text}", path, :id => "#{dir}-link"
    else
      "<span style=\"color:gray\">#{text}</span>"
    end
  end

  def cust_from_house dir
    return nil unless @customer.house # customer have no house?
    @customers_for_link ||= @customer.house.customers.sort_by{|c| c.flat.to_i}
    idx = @customers_for_link.index(@customer)
    return nil unless idx # customer moved to another house?
    if dir == :prev
      idx == 0 ? nil : @customers_for_link[idx-1]
    else # dir = :next
      idx == (@customers_for_link.size-1) ? nil : @customers_for_link[idx+1]
    end
  end

  def traf_value t, tag=nil, type=''
    t = t.to_i
    is_local = type['local']
    a, l =
      if t < 512
        ['','']
      elsif t >= 10.gigabytes
        [t/1073741824, 'G']
      elsif t > 1.gigabyte
        [("%1.1f" % (t/1073741824.0)), 'G']
      elsif t > 1.megabyte
        [t/1048576, 'M']
      else
        [t/1024, 'k']
      end
    klass = l
    title = number_with_delimiter(t, :delimiter => ' ')
    if @max_day_traf && !is_local && t > @max_day_traf
      klass += " red"
      title += "; превышен максимум в #{number_to_human_size(@max_day_traf)} !"
    end
    klass += " local" if is_local
    tag ? "<#{tag} class=\"#{klass}\" title=\"#{title}\">#{a}<i>#{l}</i></#{tag}>" : "#{a}#{l}"
  end
end
