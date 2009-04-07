# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def user_link user
    return nil unless user
    #image_tag('user-black.png', :class => 'user') + user.login
    "<a class=user>" + h(user.login) + "</a>"
  end
end
