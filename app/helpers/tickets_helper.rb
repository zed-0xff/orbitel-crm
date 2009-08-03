module TicketsHelper
  def contact_types_for_select
    [
      [ "Физ.лицо", Ticket::CONTACT_TYPE_FIZ ],
      [ "Юр.лицо",  Ticket::CONTACT_TYPE_UR  ]
    ]
  end

  def priority_desc pr
    case pr
      when Ticket::PRIORITY_HIGHEST
        "Наивысший"
      when Ticket::PRIORITY_HIGH
        "Высокий"
      when Ticket::PRIORITY_NORMAL
        "Нормальный"
      when Ticket::PRIORITY_LOW
        "Низкий"
      when Ticket::PRIORITY_LOWEST
        "Низший"
      else
        "?? #{pr} ??"
    end
  end

  def priority_style pr
    case pr
      when Ticket::PRIORITY_HIGHEST
        "color:#990000; background: #ffc4c4"
      when Ticket::PRIORITY_HIGH
        "color:#990000; background: #fff2f2"
      when Ticket::PRIORITY_NORMAL
        ""
      when Ticket::PRIORITY_LOW
        "color:#555599; background: #f2faff"
      when Ticket::PRIORITY_LOWEST
        "color:#555599; background: #ddf2ff"
      else
        "color:yellow; background: black"
    end
  end

  def priorities_for_select selected
    selected ||= 0
    Ticket::PRIORITIES.map do |pr|
      "<option style=\"#{priority_style(pr)}\" value=\"#{pr}\"" +
      ((selected == pr) ? ' selected="selected"' : '') +
      ">#{priority_desc(pr)}</option>"
    end
  end

  def ticket_status_desc st
    case st
      when Ticket::ST_NEW, nil
        "новая"
      when Ticket::ST_CLOSED
        "закрыта"
      when Ticket::ST_ACCEPTED
        "в обработке"
      when Ticket::ST_REOPENED
        "переоткрыта"
      else
        "?? #{st} ??"
    end
  end

  def history_desc he, length = nil
    d = case [he.old_status, he.new_status]
      when [nil, Ticket::ST_NEW]
        ["создал заявку", "создала заявку"]
      when [Ticket::ST_NEW, Ticket::ST_ACCEPTED],
           [Ticket::ST_REOPENED, Ticket::ST_ACCEPTED]
        ["принял заявку в обработку", "приняла заявку в обработку"]
      when [Ticket::ST_ACCEPTED, Ticket::ST_CLOSED]
        ["закрыл заявку", "закрыла заявку"]
      when [Ticket::ST_CLOSED, Ticket::ST_REOPENED]
        ["переоткрыл заявку", "переоткрыла заявку"]
      when [nil, nil]
        ""
      else
        "\"#{ticket_status_desc(he.old_status)}\" &rarr; \"#{ticket_status_desc(he.new_status)}\""
    end

    desc = if d.is_a?(Array)
      d[ he.user.male?? 0 : 1 ]
    else
      d
    end

    if he.comment
      desc += "<br/>" unless desc.blank?
      desc += "<b>" 
      desc += h(length ? truncate(he.comment, length) : he.comment).gsub("\n","<br/>")
      desc += "</b>"
    end
    desc
  end

  def link_to_tickets title, path, conditions = {}, options = {}
    @cached_counts ||= Rails.cache.read('ticket.counts') || {}
    @cached_counts = @cached_counts.dup if @cached_counts.frozen?
    cache_subkey = conditions.inspect.hash.to_s
    if options[:all_depts]
      path += "?all_depts=1"
      cache_subkey += '.all_depts'
      tickets_source = Ticket
    else
      cache_subkey += ".u#{current_user.id}"
      tickets_source = Ticket.for_user(current_user)
    end

    unless (count = @cached_counts[cache_subkey])
      count = tickets_source.count :conditions => conditions
      @cached_counts[cache_subkey] = count
      Rails.cache.write 'ticket.counts', @cached_counts.dup
    end

    if title.blank?
      link_to "#{count}", path
    else
      link_to "#{title}(#{count})", path
    end
  end

  def ajax_street_selector
    r = ''
    r+= "<div class='fieldWithErrors'>" if @ticket.errors.on(:house_street)
    r+= text_field_with_auto_complete(:street, :name, 
      {
        :size  => 20,
        :name  => 'ticket[house_attributes][street]',
        :value => (
          (@ticket.house && @ticket.house.street && @ticket.house.street.name) ||
          ( params[:ticket].try(:[], :house_attributes).try(:[], :street) )
        )
      },
      :url  => auto_complete_streets_path,
      :indicator => 'ai1'
    )
    r+= "</div>" if @ticket.errors.on(:house_street)
    r+= image_tag 'ajax.gif', :style => 'position:absolute; display:none',:id => 'ai1'
    r
  end

  def ajax_customer_selector options={}
    r = ''
    r+= label(:customer, :name, options[:label]) if options[:label]
    r+= text_field_with_auto_complete(:customer, :name, {
          :size => 40,
          :name => 'ticket[customer]',
        },
        :url => auto_complete_customers_path,
        :indicator => 'ai2'
    )
    r+= image_tag 'ajax.gif', :style => 'position:absolute; display:none',:id => 'ai2'
    r
  end

  def ur_tariffs_for_select
    @tariffs_for_select ||= Tariff.all #:conditions => [ "avail_ur = ? OR avail_fiz = ?", true, true ]
    @tariffs_for_select.find_all(&:avail_ur).map{ |t| [t.name, t.id] }
  end

  def fiz_tariffs_for_select
    @tariffs_for_select ||= Tariff.all #:conditions => [ "avail_ur = ? OR avail_fiz = ?", true, true ]
    @tariffs_for_select.find_all(&:avail_fiz).map{ |t| [t.name, t.id] }
  end
end
