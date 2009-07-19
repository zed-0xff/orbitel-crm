# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # date with '(today)' mark if date is today
  def date_with_mark date
    date.to_s + (date == Date.today ? " (сегодня)" : '')
  end

  def link_to_address_of obj
    return nil unless obj
    house = obj.is_a?(House) ? obj : obj.house
    return nil unless house
    title = obj.address.to_s.sub(/-[^-]+$/,'<span style="color:#b8b8b8">\0</span>')
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
    link_to title, house_path(house), :class => klass
  end
  alias :link_to_address :link_to_address_of
end
