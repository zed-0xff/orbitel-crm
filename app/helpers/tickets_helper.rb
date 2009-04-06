module TicketsHelper
  def contact_types_for_select
    [
      [ "Физ.лицо", Ticket::CONTACT_TYPE_FIZ ],
      [ "Юр.лицо",  Ticket::CONTACT_TYPE_UR  ]
    ]
  end
end
