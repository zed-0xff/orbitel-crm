desc "Do an initial application setup (rename & copy configs, create default users, etc)"
task :setup do
  if File.exists? "#{RAILS_ROOT}/config/database.yml"
    logger.warn "config/database.yml already exists. Skipping."
  else
    FileUtils.cp "#{RAILS_ROOT}/config/database.yml.sample", "#{RAILS_ROOT}/config/database.yml"
    logger.info "created config/database.yml"
  end
  logger.info "now please edit config/database.yml to specify your own database params"
  logger.info "   'rake setup:admin' to create only initial admin user"
  logger.info "OR 'rake setup:data'  to create admin and some other sample data like Streets, etc"
end

namespace :setup do
  desc "create inital admin user"
  task :admin => 'db:load_config' do
    unless defined?Admin
      require "#{RAILS_ROOT}/config/environment"
    end

    begin
      ActiveRecord::Base.connection
    rescue
      logger.info "running 'db:create' task.."
      Rake::Task['db:create'].invoke
    end

    unless User.table_exists?
      logger.info "running 'db:migrate' task.."
      Rake::Task['db:migrate'].invoke
    end

    if Admin.count > 0
      logger.warn "admins already present in DB!"
    else
      yaml = YAML.load_file "#{RAILS_ROOT}/spec/fixtures/default_admin.yml"
      admin = Admin.create! yaml['admin']
      logger.info "Created admin with id=#{admin.id}"
      Settings['nights.managed_by'] = [admin.id]
    end
  end

  desc "create initial sample data"
  task :data => :admin do
    ENV['EXTENDED_SEED'] = 'true'
    Rake::Task['db:seed'].invoke
  end
end

def logger
  return @zlogger if @zlogger
  require 'zlogger'
  @zlogger = ZLogger.new :date_format => ''
end
