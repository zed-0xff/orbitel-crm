#!/usr/bin/env ruby
require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)

if Admin.count > 0
  puts "[!] admins already present in DB!"
else
  yaml = YAML.load_file "#{RAILS_ROOT}/spec/fixtures/default_admin.yml"
  admin = Admin.create! yaml['admin']
  puts "[.] Done! admin id=#{admin.id}"
end


%w'Гоголя М.Горького Ленина Пролетарская'.each do |street_name|
  s = Street.new :name => street_name
  if s.valid?
    s.save!
  else
    puts "[!] #{street_name}: #{s.errors.full_messages}"
  end
end
