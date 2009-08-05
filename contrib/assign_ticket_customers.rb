#!./script/runner
#
# Ищем все заявки (Ticket), у которых проставлен contact_name, но не проставлен
# customer_id, и пытаемся по contact_name найти соответствующего абонента.
#

STDOUT.sync = true

stats = Hash.new(0)

tickets = Ticket.all(
  :conditions => [
    "customer_id IS NULL",
    "contact_name IS NOT NULL",
    "CHAR_LENGTH(contact_name) > 10"
  ].join(' AND '),
  :order => "id",
  :include => { :house => :street }
)

stats[:tickets] = tickets.size

tickets.each do |ticket|
  puts "[.] ##{ticket.id}: #{ticket.contact_name} (#{ticket.address})"
  c   = Customer.find_by_name_and_address("#{ticket.contact_name} (#{ticket.address})")
  c ||= Customer.find_by_name_and_address(ticket.contact_name)
  if c
    ticket.customer = c
    if ticket.save
      puts "[*] saved"
      stats[:saved] += 1
    else
      puts "[!] error saving"
      stats[:errors] += 1
    end
  end
end

puts stats.inspect
