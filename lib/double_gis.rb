require 'socket'
require 'iconv'
require 'yaml'

class Numeric
  def metres
    self * 100
  end

  def km
    self * 100000
  end

  alias :meters :metres
  alias :meter  :metres
  alias :metre  :metres
  alias :m      :metres
end

class DoubleGis
  def initialize params = {}
    @host  = params[:host]  || 'localhost'
    @port  = params[:port]  || 4783
    @debug = params[:debug] || false

    @default_width = params[:default_width]  || 800
    @default_height= params[:default_height] || 600

    if params[:cache]
      @cache_file = params[:cache_file] || '2gis.cache'
      if File.exists?(@cache_file)
        @cache = YAML::load_file(@cache_file)
      end
      @cache ||= {}
      raise "cache is not a hash but #{@cache.class}" unless @cache.is_a?(Hash)
    else
      @cache = false
    end
  end

  # Преобразование адреса дома в его координаты
  def house_coords street, house
    house = house.to_s if house
    addr = 
      if house
        raise "Do not use double quotes when using 2-arguments syntax" if street['"'] || house['"']
        "\"#{street.strip}\" \"#{house.strip}\""
      else
        street.strip
      end
    raise "NULL input string" unless addr
    raise "too short input string" if addr.size < 4
    raise "Input string must have at least one space" unless addr[' ']
    raise "Input string must have at least one digit" unless addr[/\d/]
    raise "Input string must not contain tabs or linefeeds" if addr[/[\t\r\n]/]
    raise "Double-quote street if it has more than one word" if addr.count(' ')>1 && !addr['"']

    r = cache_get(addr)
    return r if r

    r = send_cmd_f( Iconv.conv('cp1251','utf-8',"f #{addr}"))
    return false if !r
    cache_store(addr,r)
    r
  end

  # расстояние между домами, в метрах
  def houses_distance h1, h2
    c1 = house_coords h1
    c2 = house_coords h2
    return nil if !c1 || !c2
    (Math.sqrt((c1[0]-c2[0])**2 + (c1[1]-c2[1])**2)).round/100.0
  end

  # returns a PNG image data or FALSE
  # width & height params are optional, default specified in constructor
  # examples:
  #   copy_map( 
  #     :x      => 200.meters, 
  #     :y      => 200.meters,
  #     :radius => 100.meters
  #   )
  def copy_map params = {}
    w = params[:width] || @default_width
    h = params[:height] || @default_height
    x1 = x2 = y1 = y2 = 0
    if params[:x] && params[:y] && params[:radius]
      r = params[:radius]
      x1 = params[:x] - r
      y1 = params[:y] - r
      x2 = params[:x] + r
      y2 = params[:y] + r
    elsif params[:x1] && params[:x2] && params[:y1] && params[:y2]
      x1 = params[:x1]
      x2 = params[:x2]
      y1 = params[:y1]
      y2 = params[:y2]
    else
      raise "Invalid params combination!"
    end

    send_cmd( ['m',x1,y1,x2,y2,w,h].join(' ') )
  end

  def local2geo x, y
    send_cmd_f("l #{x} #{y}")
  end

  def geo2local x, y
    send_cmd_f("g #{x} #{y}")
  end

  def utm2local x, y
    send_cmd_f("u #{x} #{y}")
  end

  def local2utm x, y
    send_cmd_f("L #{x} #{y}")
  end

  def full_extent
    send_cmd_f('e')
  end

  def clear_cache remove_file = false
    return false unless @cache
    @cache = {}
    File.unlink(@cache_file) if remove_file
  end

  def flush_cache
    return false unless @cache
    File.open @cache_file, 'w' do |f|
      f.write(@cache.to_yaml)
    end
    true
  end

  private

  # send cmd and parse result floats
  def send_cmd_f cmd
    r = send_cmd(cmd)
    return false if !r || r.empty?
    r.split(' ').map do |x|
      xi = x.to_i
      xf = x.to_f
      xf == xi ? xi : xf
    end
  end

  def send_cmd cmd
    socket = TCPSocket.new( @host, @port )
    socket.write( "#{cmd}\n" )
    r = socket.read(4)
    if r.size!=4 || r!='4GIZ'
      socket.close
      raise "Invalid response! (#{r.inspect})"
      #return false
    end
    r = socket.read(4)
    len = r.to_s.unpack('l').first
    puts "[d] got data len: #{len}" if @debug
    r = socket.read(len)
    socket.close
    puts "[d] got data: #{r.to_s[0..40].inspect}.." if @debug
    r.to_s.strip
  end

  def cache_get key
    puts "[d] cache_get #{key}" if @debug
    return false unless @cache
    @cache[key]
  end

  def cache_store key,value
    return false unless @cache
    @cache[key] = value
  end
end

##########################################################

if $0 == __FILE__

  puts "[.] test"
  puts "[*] w/o cache:"
  gis = DoubleGis.new(:cache => false, :debug => true)
  puts "[.] house coords: #{gis.house_coords("Советская", "123").inspect}"
  puts

  puts "[*] with cache:"
  gis = DoubleGis.new(:cache => true, :debug => true)
  puts "[.] house coords: #{(r=gis.house_coords("Советская", "123")).inspect}"
  puts

  #gis.flush_cache
  
  c = gis.house_coords "Пичугина", "16"

  puts "[*] copy_map:"
  r = gis.copy_map :x => c[0], :y => c[1], :radius => 100.m, :width => 512, :height => 512
  File.open('2gis_test.png','w') do |f|
    f.write(r)
  end
  puts

  gis = DoubleGis.new(:cache => true)
  c = gis.house_coords "Пичугина", "16"
  puts "[*] pichu 16: #{c.inspect}"

  c = gis.house_coords "Коли Мяготина", "123"
  puts "[*] km 123: #{c.inspect}"

  c = gis.house_coords "Куйбышева", "35"
  puts "[*] kui 35: #{c.inspect}"

  c = gis.house_coords "ушошуов", "35"
  puts "[*] non-exists: #{c.inspect}"

  c = gis.house_coords "Омская", "1"
  puts "[*] omsk1: #{c.inspect}"

=begin
  puts "[*] local2geo(#{c.inspect}):"
  puts (c=gis.local2geo(*c)).inspect
  puts "[*] geo2local(#{c.inspect}):"
  puts (c=gis.geo2local(*c)).inspect
  puts "[*] local2geo(#{c.inspect}):"
  puts (c=gis.local2geo(*c)).inspect
  puts "[*] geo2local(#{c.inspect}):"
  puts (c=gis.geo2local(*c)).inspect
  puts
=end
  puts "[*] full extent = #{gis.full_extent.inspect}"
  puts "[*] full extent = #{gis.full_extent.map{|x| x/1.0.m}.inspect} (m)"

#  puts gis.geo2local(65.3466796875, 55.43701171875).inspect;
#  puts gis.geo2local(65.32470703125, 55.43701171875).inspect;
end

