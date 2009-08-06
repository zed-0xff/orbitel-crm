#!./script/runner
STDOUT.sync = true

require 'krus'

puts "[.] customers in db BEFORE import: #{Customer.count}"

stats = Hash.new(0)
h = {}
Customer.all(:conditions => 'external_id IS NOT NULL').each do |customer|
  h[customer.external_id] = customer
end

puts "[.] loading krus customers.."
krus_customers = Krus.fetch_customers
#  if File.exists?('krus_customers.yml')
#    YAML.load_file 'krus_customers.yml'
#  else
#    Krus.fetch_customers
#  end
#
#File.open 'krus_customers.yml','w' do |f|
#  f.write(krus_customers.to_yaml)
#end

puts "[.] loaded #{krus_customers.size} krus customers"

krus_customers.each do |kc|
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
      c.krus_sync_date = Time.now
      stats[:updated] += 1
    end
    c.save!
  else
    c = Customer.new(
      :external_id   => kc[:id],
      :krus_sync_date => Time.now,
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
