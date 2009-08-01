module CallsHelper
  def distance_of_time_in_images call
    d = 
      if call.respond_to?(:duration)
        call.duration
      else
        call
      end

    d = d.to_i
    title = 
      if d >= 60
        "%dm %02ds" % [d/60, d%60]
      else
        "#{d}s"
      end

    if call.respond_to?(:ended?) && !call.ended?
      nminutes = call.duration / 60
      nminutes = 1 if nminutes < 1
      nminutes = 5 if nminutes > 5
      return image_tag('balloon.png', :title => title) * nminutes.to_i
    end

    if d==0
      image_tag 'exclamation.png', :title => "Неотвеченный звонок (#{title})"
    elsif d<=20
      image_tag 'clock-quarter.png', :title => title
    elsif d<=40
      image_tag 'clock-half.png', :title => title
    elsif d<=70
      image_tag 'clock-full.png', :title => title
    elsif d<=100
      image_tag('clock-full.png', :title => title) + image_tag('clock-half.png', :title => title)
    elsif d <= 5*60+30
      image_tag('clock-full.png', :title => title) * ((d+20)/60)
    elsif d <= 6*60+30
      image_tag('clock-full.png', :title => title) * 4 +
        image_tag('clock-full-plus.png', :title => title) * 1
    elsif d <= 7*60+30
      image_tag('clock-full.png', :title => title) * 3 +
        image_tag('clock-full-plus.png', :title => title) * 2
    elsif d <= 8*60+30
      image_tag('clock-full.png', :title => title) * 2 +
        image_tag('clock-full-plus.png', :title => title) * 3
    elsif d <= 9*60+30
      image_tag('clock-full.png', :title => title) * 1 +
        image_tag('clock-full-plus.png', :title => title) * 4
    else
      image_tag('clock-full-plus.png', :title => title) * 5
    end
  end
end
