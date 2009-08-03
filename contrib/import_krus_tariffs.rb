#!./script/runner
STDOUT.sync = true

require 'krus'

puts "[.] tariffs in db BEFORE import: #{Tariff.count}"

stats = Hash.new(0)
h = {}
Tariff.all(:conditions => 'external_id IS NOT NULL').each do |tariff|
  h[tariff.external_id] = tariff
end

puts "[.] loading krus tariffs.."
krus_tariffs = 
  if File.exists?('krus_tariffs.yml')
    YAML.load_file 'krus_tariffs.yml'
  else
    Krus.fetch_tariffs
  end

#File.open 'krus_tariffs.yml','w' do |f|
#  f.write(krus_tariffs.to_yaml)
#end

puts "[.] loaded #{krus_tariffs.size} krus tariffs"

krus_tariffs.each do |kt|
  stats[:total] += 1
  if t = h[kt['id']]
    t.name     = kt['name'] if kt['name']
    t.avail_ur = kt['avail_ur']
    t.avail_fiz= kt['avail_fiz']
    if t.changed?
      puts "[*] updating #{t.name.inspect}"
      stats[:updated] += 1
    end
    t.save!
  else
    t = Tariff.new(
      :external_id    => kt['id'],
      :name           => kt['name'],
      :avail_ur       => kt['avail_ur'],
      :avail_fiz      => kt['avail_fiz']
    )
    begin
      t.save!
      stats[:new] += 1
    rescue
      puts "[!] error processing #{t.inspect}"
      raise
    end
    puts "[+] created #{t.name.inspect}"
  end
end

puts "[.] tariffs in db AFTER  import: #{Tariff.count}"
puts "[s] #{stats.inspect}"
