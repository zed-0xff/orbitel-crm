require 'logger'
class ZLogger < Logger
  def initialize(hint = {})
    super(hint[:file] || STDOUT)

    self.formatter = Formatter.new
    self.formatter.datetime_format = hint[:date_format] || "%d.%m %H:%M:%S:"
  end

  def dot
    if @logdev.dev == STDOUT
      formatter.instance_variable_set('@wasdot', true)
      putc '.'
      if !@lastflush || (Time.now-@lastflush) >= 0.2
        STDOUT.flush
        @lastflush = Time.now
      end
    end
  end

  # string to prepend to all lines
  def prepend= s
    self.formatter.prepend = s
  end

  class Formatter < Logger::Formatter
    attr_accessor :prepend

    def call(severity, time, progname, msg)
      self.prepend.to_s +
      if severity == 'INFO' && msg.nil?
        @wasdot = false
        # use this if you want a simple blank line without date in your logs:
        # just call a logger.info without any params // zzz :)
        "\n"
      else
        pre = case severity
          when 'WARN'
            '[?]'
          when 'ERROR', 'FATAL'
            '[!]'
          when 'DEBUG'
            '[d]'
          else
            '[.]'
        end
        pre = "\n#{pre}" if @wasdot
        @wasdot = false
        t = format_datetime(time)
        pre << (t == '' ? '' : " #{t}") << " " <<  msg2str(msg) << "\n"
      end
    end  
  end
end
