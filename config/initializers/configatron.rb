require 'configatron'
#Configatron::Rails.init
configatron.configure_from_yaml( Rails.root + 'config/crm.defaults.yml' )
if File.exist?( Rails.root + 'config/crm.yml' )
  configatron.configure_from_yaml( Rails.root + 'config/crm.yml' )
end
