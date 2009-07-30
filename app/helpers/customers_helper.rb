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
    customer_link "&larr;", "<", true
  end

  def next_customer_link
    customer_link "&rarr;", ">"
  end

  private

  def customer_link text, cmp, desc = false
    raise "Invalid cmp!" if cmp.size != 1

    cust = Customer.first(
      :conditions => ["id #{cmp} ?", @customer.id],
      :order => ( desc ? "id DESC" : "id" )
    )
    if cust
      link_to text, customer_path(cust)
    else
      "<span style=\"color:gray\">#{text}</span>"
    end
  end
end
