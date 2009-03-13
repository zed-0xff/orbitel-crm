#!/usr/bin/env ruby
require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)
if Admin.count > 0
  puts "[!] admins already present in DB!"
  exit 1
end

yaml = YAML.load_file "#{RAILS_ROOT}/spec/fixtures/default_admin.yml"
admin = Admin.create! yaml['admin']
puts "[.] Done! admin id=#{admin.id}"
