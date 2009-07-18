# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # date with '(today)' mark if date is today
  def date_with_mark date
    date.to_s + (date == Date.today ? " (сегодня)" : '')
  end
end
