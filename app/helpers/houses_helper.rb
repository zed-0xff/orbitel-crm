module HousesHelper
  def status_tag house, type, tag='div'
    st = house.send("#{type}_status")
    "<#{tag} style='background:#{status_color(st)}'>#{status_desc(st)}</#{tag}>"
  end

  def status_desc st
    case st
      when House::ST_YES
        "Подключаем"
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
        'green'
      when House::ST_NO
        'red'
      when nil
        'lightgrey'
      else
        'magenta'
    end
  end

  def statuses_for_select
    options_for_select(
      [House::ST_YES, House::ST_NO].map{|st| [status_desc(st),st] }
    )
  end
end
