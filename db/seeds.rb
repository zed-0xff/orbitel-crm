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

  #############################################################################
  # generate customers

  if configatron.billing.klass.to_s.downcase['sample']
    load(Rails.root+'contrib/import_billing_users.rb')
  end

  #############################################################################
  # generate phone calls

  customers = Customer.all

  if Radius::Call.count < 50
    phones    = Phone.all.map(&:number)
    (phones.size/2).times do
      # 30% unknown phone numbers
      phones << Billing::Sample::generate_phone.to_s.tr('-','').to_i
    end
    if customers.any?
      start = Time.now - 10.hours
      50.times do
        len = rand(100) < 15 ? 0 : rand(5*60) # 15% unanswered calls
        Radius::Call.create(
          :acctstarttime    => start,
          :acctstoptime     => start+len,
          :acctsessiontime  => len,
          :callingstationid => phones.rand
        )
        start += len + rand(10*60)
      end
    end
  end

  #############################################################################
  # generate tickets

  users = User.all

  if Ticket.count < 30
    tickets = []
    titles = [
      'нет сети',
      'нет интернета',
      'потери 30%',
      'абонент недоволен скоростью',
      'потери 5%',
      'СКНП'
    ]
    comments = [
      'обрыв кабеля',
      'сделаем завтра',
      'нет ключей от чердака',
      'должен работать',
      'возможно DNS не правильно прописан или в браузере ошибка',
      'надо менять оборудование на узле',
      'у абонента было выключено сетевое подключение',
      'пингуется без потерь',
      'зависание у/с',
      'кабель поврежден на 5 этаже, порезан немного',
      'проблемы с виндой',
      'ну что, починили?'
    ]
    30.times do
      tickets << Ticket.create!(
        :created_by => users.rand,
        :customer   => customers.rand,
        :title      => titles.rand
      )
      sleep 0.1
      if rand(100) < [30,tickets.size].max
        ticket = tickets.rand
        ticket.history.create!(
          :user    => users.rand,
          :comment => comments.rand
        )
        sleep 0.1
      end
      if rand(100) < 20
        ticket = tickets.rand
        if ticket.status == Ticket::ST_NEW
          ticket.change_status! Ticket::ST_ACCEPTED, :user => users.rand, :assign => true
        end
        sleep 0.1
      end
    end
  end
end
