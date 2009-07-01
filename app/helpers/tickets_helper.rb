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

  def status_desc st
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
        "\"#{status_desc(he.old_status)}\" &rarr; \"#{status_desc(he.new_status)}\""
    end

    desc = if d.is_a?(Array)
      d[ he.user.male?? 0 : 1 ]
    else
      d
    end

    if he.comment
      desc += "<br/>" unless desc.blank?
      desc += "<b>" 
      desc += h(length ? truncate(he.comment, length) : he.comment)
      desc += "</b>"
    end
    desc
  end

  # date with '(today)' mark if date is today
  def date_with_mark date
    date.to_s + (date == Date.today ? " (сегодня)" : '')
  end
end
