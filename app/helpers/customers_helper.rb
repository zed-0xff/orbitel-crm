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
        r += "<div title='Процент от максимально возможного на текущую дату' class='#{klass}'>(%2d%%)</div>" % percent
      end
    end
    r
  end

  def prev_customer_link
    customer_link :prev
  end

  def next_customer_link
    customer_link :next
  end

  private

  def customer_link dir
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
      opts = {}
      opts[:from] = params[:from] if params[:from]
      link_to text, customer_path(cust, opts)
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
end
