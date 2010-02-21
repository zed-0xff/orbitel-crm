#!./script/runner
STDOUT.sync = true

puts "[.] customers in db BEFORE import: #{Customer.count}"

stats = Hash.new(0)
h = {}
Customer.all(:conditions => 'external_id IS NOT NULL').each do |customer|
  h[customer.external_id] = customer
end

puts "[.] loading billing customers.."
billing_customers = Billing.fetch_users
#  if File.exists?('billing_customers.yml')
#    YAML.load_file 'billing_customers.yml'
#  else
#    Billing.fetch_users
#  end
#
#File.open 'billing_customers.yml','w' do |f|
#  f.write(billing_customers.to_yaml)
#end

puts "[.] loaded #{billing_customers.size} billing customers"

billing_customers.each do |kc|
  stats[:total] += 1
  if c = h[kc[:id]]
    c.name = Customer.cleanup_name(kc[:name]) if kc[:name]
    c.phones.add kc[:phones]
    c.address = kc[:address] unless kc[:address].blank?
    #unless kc[:address].blank?
    #  puts "\t#{kc[:address]}"
    #  puts "\t#{c.house.street.name} - #{c.house.number} - #{c.flat}"
    #end
    if c.house && c.house.invalid?
      puts "[!] failed to parse #{kc[:address].inspect} (##{kc[:id]})"
      c.house = nil
      stats[:failed] += 1
    end
    if c.changed?
      puts "[*] updating #{c.name.inspect}"
      c.billing_sync_date = Time.now
      stats[:updated] += 1
    end
    c.save!
  else
    c = Customer.new(
      :external_id   => kc[:id],
      :billing_sync_date => Time.now,
      :name           => kc[:name],
#      :address        => kc[:address],
      :phones         => kc[:phones]
    )
    c.address = kc[:address] unless kc[:address].blank?
    if c.house && c.house.invalid?
      puts "[!] failed to parse #{kc[:address].inspect} (##{kc[:id]})"
      c.house = nil
      stats[:failed] += 1
    end
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
      stats[:new] += 1
    rescue
      puts "[!] error processing #{c.inspect}"
      raise
    end
    puts "[+] created #{c.name.inspect}"
  end
end

puts "[.] customers in db AFTER  import: #{Customer.count}"
puts "[s] #{stats.inspect}"
