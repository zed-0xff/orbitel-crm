class TicketStatusNotNull < ActiveRecord::Migration
  def self.up
    Ticket.all(:conditions => "status IS NULL").each do |ticket|
      ticket.update_attribute :status, Ticket::ST_NEW
    end
    change_column_null :tickets, :status, false, Ticket::ST_NEW
    change_column_default :tickets, :status, Ticket::ST_NEW
  end

  def self.down
    change_column_null :tickets, :status, true
  end
end
