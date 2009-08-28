module NightsHelper
  def wday_td date, klass='', &block
    buffer = ''
  
    klass += " weekend" if [6,7].include?(date.cwday)
    klass += " today" if date == Date.today

    buffer << "<td class=\"#{klass}\">"

    if block_given?
      buffer <<
        if block_called_from_erb?(block)
          with_output_buffer { block.call }
        else
          # Return block result otherwise, but protect buffer also.
          with_output_buffer { return block.call }
        end
    end

    buffer << "</td>"

    block_given? ? output_buffer.concat(buffer) : buffer
  end

  def draw_vacation vacation, date
    @drawed_vacations ||= {}
    return '<td style="display:none"></td>' if @drawed_vacations[vacation.id]
    @drawed_vacations[vacation.id] = true
    ndays = 
      [vacation.end_date, Date.civil(date.year, date.mon, -1)].min -
      [vacation.start_date, date].max + 1
    "<td class=\"vacation\" colspan=\"#{ndays}\">отпуск"
  end

  # TODO: implement thru i18n
  def wday_shortname date
    %w'вс пн вт ср чт пт сб'[date.wday]
  end

  def link_to_next_month title='&raquo;'
    month = @month + 1
    year  = @year
    if month == 13
      month = 1
      year += 1
    end
    link_to title, {:month => month, :year => year}, :class => 'noprint'
  end

  def link_to_prev_month title='&laquo;'
    month = @month - 1
    year  = @year
    if month == 0
      month = 12
      year -= 1
    end
    link_to title, {:month => month, :year => year}, :class => 'noprint'
  end
end
