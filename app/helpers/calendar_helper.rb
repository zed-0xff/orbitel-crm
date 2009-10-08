module CalendarHelper
  def link_to_tickets dt, tag = nil, title = "Заявок создано"
    klass = tag ? "tickets-#{tag}"        : 'tickets'
    param = tag ? "#{tag}_at"             : 'created_at'
    tag   = tag ? "#{tag}_tickets".to_sym : :tickets
    unless @dobjects[dt][tag].blank?
      link_to @dobjects[dt][tag], all_tickets_path(param => dt), :class => klass, :title => title
    end
  end

  def extrapolate value
    e = Date.today.end_of_month
    if Date.today < e && value.to_i > 0 && params[:pos].to_i == 0
      t = (1.0 * value.to_i / Date.today.day * e.day).to_i
      "<span class=\"extrapolate\" title=\"прогноз\">#{t}</span>"
    end
  end

  def prev_month_link opts = {}
    month_link :prev, opts
  end

  def next_month_link opts = {}
    month_link :next, opts
  end

  private

  def month_link dir, opts = {}
    pos = params[:pos].to_i

    case dir
      when :prev
        pos -= 1
        text = '&larr;'
      when :next
        pos += 1
        text = '&rarr;'
      else
        raise "Invalid direction: #{dir.inspect}"
    end


    if pos <= 0
      link_to "<b>ctrl</b>#{text}", {:pos => pos}, :id => "#{dir}-link"
    else
      "<span style=\"color:lightgrey\">#{text}</span>"
    end
  end

end
