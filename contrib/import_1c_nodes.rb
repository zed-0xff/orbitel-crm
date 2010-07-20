#!./script/runner
$KCODE='u'
require 'iconv'
require 'rubygems'
require 'dbf'
require 'pp'

config = YAML::load_file(__FILE__.sub(/\.rb$/,".yml"))

DD_FNAME   = config['dd_fname']

SMB_USER   = config['smb']['user']
SMB_PASS   = config['smb']['pass']
SMB_HOST   = config['smb']['host']
SMB_SHARE  = config['smb']['share']
SMB_CLIENT = config['smb']['client']  || '/usr/bin/smbclient'
SMB_TMP_DIR= config['smb']['tmp_dir'] || "/tmp"

class SmbClient
  def get_file fname, do_unlink = true
    local_fname = SMB_TMP_DIR + "/smb.#{Time.new.to_i}.#{$$}.#{rand(65536)}.tmp"
    msg = `#{SMB_CLIENT} -l /dev/null -U #{SMB_USER} //#{SMB_HOST}/#{SMB_SHARE} #{SMB_PASS} -c "get #{fname} #{local_fname}"`
    if $?.success?
      r = open(local_fname)
      File.unlink(local_fname) if do_unlink
      r
    else
      raise "smb failed: #{$?.to_i}: #{msg.strip.inspect}"
    end
  end
end

class OneEsClient

  IMPORTANT_FIELDS = {
    'ВышестоящийУзел'    => :parent,
    'ТипОбъектаСвязи'    => :type,
    'object description' => :address,
    'ID object'          => :id
  }

  Node = Struct.new(:id, :type, :parent, :address)

  TYPES = {
    '0'   => 'неопределен',
    'QPB' => 'магистральный узел',
    'QPC' => 'районный узел',
    'QPD' => 'локальный узел',
    'QPE' => 'абонент'
  }

  def initialize(dd_fname)
    @field_names = {}
    @important_fields = {}
    @dd = SmbClient.new.get_file(dd_fname)
  end
  def nodes_table_name
    data = Iconv.conv("utf-8","cp1251",@dd.read)
    idx = data.index(/^T=([A-Z0-9]+).*Справочник МестаХранения/)
    raise "[!] can't find 'Справочник МестаХранения'" unless idx
    tablename = $1
    # skip all info before this tabledef
    data = data[idx..-1]
    data.each_line do |line|
      if line =~ /^F=/
        line.strip!
        a = line.sub(/^F=/,'').split('|').map(&:strip)
        @field_names[a[0].upcase] = a[1]
      end
      break if line['=================']
    end
    IMPORTANT_FIELDS.each do |ifield,ikey|
      @field_names.each do |k,v|
        @important_fields[k] = ikey if v[ifield]
      end
    end
    tablename
  end
  def get_nodes_dbf do_unlink = true
    SmbClient.new.get_file(nodes_table_name+".DBF", do_unlink)
  end
  def get_nodes
    dbf = get_nodes_dbf(false)
    table = DBF::Table.new(dbf.path)
    File.unlink(dbf.path)

    a = []
    table.each do |row|
      next if row.attributes['ISMARK'].strip == '*' # deleted rows
      r = Node.new
      @important_fields.each do |fkey,ftitle|
        v = row.attributes[fkey]
        v = v.is_a?(String) ? Iconv.conv("utf-8","cp1251",v) : v
        r.send("#{ftitle}=",v)
      end
      t = r.type
      #p row if r.address['Горького 155'] && t!='QPE'
      #next if t == 'QPE' # skip abonents
      if t1 = TYPES[t]
        r.type = t1
      else
        raise "Unknown type #{t.inspect} for #{r.inspect}"
      end
      a << r
    end
    a
  end
end

puts "[.] getting nodes from 1C.."
a = OneEsClient.new(DD_FNAME).get_nodes
puts "[.] got #{a.size} nodes"

nodes = {}
Node.all.each do |node|
  nodes[node.external_id] = node
end

puts "[.] updating nodes info.."
a.each do |nodeinfo|
  if node = nodes[nodeinfo.id]
    node.update_attributes!(
      :name => nodeinfo.address, :external_id => nodeinfo.id, :nodetype => nodeinfo.type
    )
  else
    begin
      node = Node.create! :name => nodeinfo.address, :external_id => nodeinfo.id, :nodetype => nodeinfo.type
    rescue
      puts "[!] error creating #{nodeinfo.inspect}"
      raise
    end
    nodes[node.external_id] = node
  end
end

puts "[.] updating parents info.."
a.each do |nodeinfo|
  node = nodes[nodeinfo.id]
  parent_node = nodes[nodeinfo.parent]
  if parent_node && node.parent_id != parent_node.id
    node.update_attribute(:parent_id, parent_node.id)
  end
end

stats = Hash.new(0)

puts "[.] associating customers with nodes.."
Node.find_all_by_nodetype('абонент').each do |node|
  next unless node.parent
  address,customer_name_part,_ = node.name.split(/[()]/,3)
  address.strip!
  unless customer_name_part
    puts "[?] no customer name part in #{node.name.inspect}"
    stats[:no_name] += 1
    next
  end
  customer_name_part.strip!
  a = address.split("-")
  house_addr = nil
  flat_num = nil
  if a.size == 2
    house_addr, flat_num = a
  elsif a.first.size > 4
    house_addr, flat_num = a[0],a[1]
  else
    house_addr, flat_num = a[0]+'-'+a[1], a[2]
  end
  house_addr.strip!
  unless flat_num
    puts "[?] no flat in address for #{node.name.inspect}"
    stats[:no_flat] += 1
    next
  end
  flat_num.strip!
  house = House.from_string(house_addr)
  if house.new_record?
    puts "[?] can't find house for #{node.name.inspect}, house_addr=#{house_addr.inspect}"
    stats[:no_house] += 1
    next
  end
  was = false
  house.customers.each do |c|
    if c.flat == flat_num && c.name[customer_name_part]
      c.update_attribute :node_id, node.parent.id
      was = true
      stats[:ok] += 1
    end
  end
  unless was
    puts "[?] can't find flat of #{node.name.inspect}"
    stats[:cannot_find_flat] += 1
  end
end

puts "[_] #{stats.inspect}"
