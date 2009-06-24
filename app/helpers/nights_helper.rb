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
end
