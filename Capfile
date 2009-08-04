load 'deploy' if respond_to?(:namespace) # cap2 differentiator
Dir['vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }
load 'config/deploy'

desc "tail production log files"
task :tail_logs, :roles => :app do
  run "tail -f #{shared_path}/log/production.log" do |channel, stream, data|
    puts  # for an extra line break before the host name
    puts "#{channel[:host]}: #{data}"
    break if stream == :err   
  end
end

desc "remote production console"
task :console, :roles => :app do
  input = ''
  run "cd #{current_path} && ./script/console production" do |channel, stream, data|
    next if data.chomp == input.chomp || data.chomp == ''
    print data
    channel.send_data(input = $stdin.gets) if data =~ /^(>|\?)>/
  end
end

namespace :krus do
  desc "import KRUS users"
  task :import_users, :roles => :app do
    run "cd #{current_path} && RAILS_ENV=production ./contrib/import_krus_users.rb"
  end

  desc "import KRUS tariffs"
  task :import_tariffs, :roles => :app do
    run "cd #{current_path} && RAILS_ENV=production ./contrib/import_krus_tariffs.rb"
  end
end
