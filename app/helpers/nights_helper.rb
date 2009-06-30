module NightsHelper
  def wday_td date, klass='', &block
    buffer = ''
  
    if [6,7].include?(date.cwday)
      klass += " weekend"
    end

    buffer << "<td class=\"#{klass}\">"

    buffer <<
      if block_called_from_erb?(block)
        with_output_buffer { block.call }
      else
        # Return block result otherwise, but protect buffer also.
        with_output_buffer { return block.call }
      end

    buffer << "</td>"

    output_buffer.concat(buffer)
  end

  def draw_vacation vacation, date
    @drawed_vacations ||= {}
    return '' if @drawed_vacations[vacation.id]
    @drawed_vacations[vacation.id] = true
    ndays = 
      [vacation.end_date, Date.civil(date.year, date.mon, -1)].min -
      [vacation.start_date, date].max + 1
    "<td class=\"vacation\" colspan=\"#{ndays}\">отпуск"
  end
end
