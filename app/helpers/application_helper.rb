# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # date with '(today)' mark if date is today
  def date_with_mark date
    date.to_s + (date == Date.today ? " (сегодня)" : '')
  end

  def link_to_address_of obj, attrs = {}
    return nil unless obj
    house = obj.is_a?(House) ? obj : obj.house
    return nil unless house
    title = house.address
    title.sub! ' проспект','' # local hack
    klass = 'house'
    house_size = Rails.cache.read "house.#{house.id}.size"
    unless house_size
      house_size = house.customers.size
      Rails.cache.write "house.#{house.id}.size", house_size, :expires_in => 8.hours
    end
    case house_size
      when 0..1:
        klass += ' house1'
      when 2..4:
        klass += ' house2'
      when 5..8:
        klass += ' house3'
      else
        klass += ' house4'
    end
    attrs[:class] ||= klass
    link_to(title, house_path(house), attrs) +
      ((obj.respond_to?(:flat) && !obj.flat.blank?) ? "<span style=\"color:#b8b8b8\">-#{obj.flat}</span>" : '')
  end
  alias :link_to_address :link_to_address_of

  def link_to_customer customer, attrs = {}, link_opts = {}
    return nil unless customer
    attrs[:class] ||= 'customer'
    unless si = Rails.cache.read("customer.#{customer.id}.status-icon")
      si = customer_link_class(customer)
      Rails.cache.write "customer.#{customer.id}.status-icon", si, :expires_in => 24.hours
    end
    if si != true
      attrs[:class] += "-#{si}"
      case si
        when 'y': attrs[:title] = "На абонента есть заявка"
        when 'r': attrs[:title] = "На абонента есть заявка с высоким приоритетом"
      end
    end
    link_to((attrs.delete(:text) || customer.name), customer_path(customer, link_opts), attrs)
  end

  # calculate a customer icon based on his CURRENT tickets
  # a) if customer has no tickets                 => simple icon
  # b) if customer has ticket with high priority  => RED sub-icon
  # c) if customer has any tickets                => YELLOW sub-icon
  #
  # this method MUST be cached for best performance
  def customer_link_class customer
    ticket = customer.tickets.current.first(
      :conditions => [ "type IS NULL OR type != ?", "TariffChange" ],
      :order => "priority DESC"
    )
    return true unless ticket
    ticket.priority > Ticket::PRIORITY_NORMAL ? 'r' : 'y'
  end

  # TODO: implement thru i18n
  def month_name month
    %w'Нулябрь Январь Февраль Март Апрель Май Июнь Июль Август Сентябрь Октябрь Ноябрь Декабрь'[month]
  end

  def handle_ctrl_arrows
    <<-EOJS
      // handle Ctrl+Left & Ctrl+Right keys 
      Event.observe(window, 'keydown', function(ev){ 
        if( ev.ctrlKey ){ 
          var link; 
          if( ev.keyCode == 0x25 )  
            link = $('prev-link'); 
          else if( ev.keyCode == 0x27 )  
            link = $('next-link'); 
     
          if( link && link.href ) document.location = link.href; 
        } 
      });
    EOJS
  end
end
