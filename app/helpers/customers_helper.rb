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
    r  = "<div class='traf-amount'>"
    r += number_to_human_size(@info[:traf_report][type]).rjust(10)
    r += "</div>"
    if @info[:bandwidth] && [:inet_out, :in_sat].include?(type)
      # max traffic amount from start of month to current day
      max_amount = @info[:bandwidth] * 1024 / 8 * 3600 * 24 * Date.today.day
      percent    = 100 * @info[:traf_report][type] / max_amount
      klass      = 'traf-amount-percent' + ((percent >= 100) ? ' red' : '')
      r += "<div title='Процент от максимально возможного на текущую дату' class='#{klass}'>(%2d%%)</div>" % percent
    end
    r
  end
end
