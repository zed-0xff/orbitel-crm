#!./script/runner
STDOUT.sync = true

require 'krus'

puts "[.] customers in db BEFORE import: #{Customer.count}"

h = {}
Customer.all(:conditions => 'krus_user_id IS NOT NULL').each do |customer|
  h[customer.krus_user_id] = customer
end

puts "[.] loading krus customers.."
krus_customers = Krus.fetch_customers

puts "[.] loaded #{krus_customers.size} krus customers"

krus_customers.each do |kc|
  if c = h[kc[:id]]
    c.krus_sync_date = Time.now
    c.name = kc[:name] if kc[:name]
    c.phones.add kc[:phones]
    c.save!
    puts "[*] synched #{c.name.inspect}"
  else
    c = Customer.new(
      :krus_user_id   => kc[:id],
      :krus_sync_date => Time.now,
      :name           => kc[:name],
#      :address        => kc[:address],
      :phones         => kc[:phones]
    )
    c.phones.delete_if do |ph|
      if !ph.valid?
        puts "[?] phone #{ph.number} is invalid"
        true
      elsif ph2 = Phone.find_by_number(ph.number)
        puts "[?] phone #{ph.number} already assigned to #{ph2.customer.name}"
        true
      else
        false
      end
    end
    begin
      c.save!
    rescue
      puts "[!] error processing #{c.inspect}"
      raise
    end
    puts "[+] created #{c.name.inspect}"
  end
end

puts "[.] customers in db AFTER  import: #{Customer.count}"
