class AddTicketClosedAt < ActiveRecord::Migration
  def self.up
    add_column :tickets, :closed_at, :datetime
    Ticket.find_all_by_status( Ticket::ST_CLOSED ).each do |t|
      t.closed_at = t.updated_at
      t.save
    end
  end

  def self.down
    remove_column :tickets, :closed_at
  end
end
