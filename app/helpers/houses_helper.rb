module HousesHelper
  def status_tag house, type, tag='div'
    st = house.send("#{type}_status")
    "<#{tag} style='background:#{status_color(st)}'>#{status_desc(st)}</#{tag}>"
  end

  def status_desc st
    case st
      when House::ST_YES
        "Подключаем"
      when House::ST_MINOR_PROBLEMS
        "Есть небольшие проблемы"
      when House::ST_MAJOR_PROBLEMS
        "Есть серьёзные проблемы"
      when House::ST_IN_PLANS
        "Возможность планируется"
      when House::ST_NO
        "Нет тех.возможности"
      when nil
        "нет данных"
      else
        "?? #{st} ??"
    end
  end

  def status_color st
    case st
      when House::ST_YES
        '#75D700'
      when House::ST_MINOR_PROBLEMS
        "#92D79D"
      when House::ST_IN_PLANS
        '#C48888'
      when House::ST_NO
        '#ff6060'
      when nil
        'lightgrey'
      else
        'magenta'
    end
  end

  def statuses_for_select selected
    House::STATUSES.map do |st|
      "<option style=\"background:#{status_color(st)}\" value=\"#{st}\"" +
      ((selected == st) ? ' selected="selected"' : '') +
      ">#{status_desc(st)}</option>"
    end.join("\n")
  end
end
