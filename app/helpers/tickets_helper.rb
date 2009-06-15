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
end
