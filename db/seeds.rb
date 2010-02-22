class String
  def self.random len
      chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
      newpass = ""
      1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
      newpass
  end
end

%w'Аргентовского Бажова Блюхера Больничная Бурова-Петрова Васильева Войкова Володарского Галкинская Гоголя        Дзержинского Заводская Загородная Зорге Интернациональная Ипподромная Карельцева Карла Кирова Климова Коли Комсомольская      Кравченко Красина Красномаячная Кремлева Криволапова Куйбышева Куртамышская Ленина Линейная Максима Машиностроителей          Менделеева Невежина Некрасова Односторонка Омская Орлова Пичугина Победы Пролетарская Проходная Пушкина Радионова Рихарда     Савельева Свердлова Советская Станционная Сухэ-Батора Тобольная Товарная Томина Уральская Урицкого Химмашевская Югова'.each do |street_name|
  Street.create :name => street_name
end

[
  ['admins',      'Админы'],
  ['technicians','Техники'],
  ['managers', 'Менеджеры'],
  ['prorabs',    'Прорабы']
].each do |handle,name|
  Dept.create :name => name, :handle => handle
end

yaml = YAML.load_file "#{RAILS_ROOT}/spec/fixtures/default_admin.yml"
admin = Admin.new yaml['admin']
if admin.save
  Settings['nights.managed_by'] = [admin.id]
end

admins_dept = Dept.find_by_handle 'admins'
managers_dept = Dept.find_by_handle 'managers'
technicians_dept = Dept.find_by_handle 'technicians'
prorabs_dept = Dept.find_by_handle 'prorabs'

Admin.all.each do |admin|
  admin.dept = admins_dept
  admin.save
end

if ENV['EXTENDED_SEED']
  def create_user klass, h
    h[:password_confirmation] = h[:password]
    klass.create h
  end

  create_user Admin, {
    :password => String.random(8),
    :login    => 'max',
    :name     => 'Максим',
    :dept_id  => admins_dept.id
  }

  create_user SuperManager, {
    :password => String.random(8),
    :login    => 'olga',
    :name     => 'Ольга',
    :dept_id  => managers_dept.id,
    :male     => false
  }

  create_user Manager, {
    :password => String.random(8),
    :login    => 'dima',
    :name     => 'Дмитрий',
    :dept_id  => managers_dept.id
  }

  create_user Technician, {
    :password => String.random(8),
    :login    => 'eduard',
    :name     => 'Эдуард',
    :dept_id  => prorabs_dept.id
  }

  create_user Technician, {
    :password => String.random(8),
    :login    => 'stas',
    :name     => 'Станислав',
    :dept_id  => technicians_dept.id
  }

  create_user Technician, {
    :password => String.random(8),
    :login    => 'serg',
    :name     => 'Сергей',
    :dept_id  => technicians_dept.id
  }

  if configatron.billing.klass.to_s.downcase['test']
    load(Rails.root+'contrib/import_billing_users.rb')
  end
end
