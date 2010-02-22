# "тестовый" виртуальный биллинг
class Billing::Test < Billing

  STREETS = %w'Аргентовского Бажова Блюхера Больничная Бурова-Петрова Васильева Войкова Володарского Галкинская Гоголя Дзержи
  нского Заводская Загородная Зорге Интернациональная Ипподромная Карельцева Карла Кирова Климова'

  NAMES = {
    :male => [
      %w"Александров Алексеев Асташов Баженов Барсуков Белобородов Бизенков Боронко Виноградов Войтюк Гамин Грибанов Дементьев Дерябин Доронин Евстегнеев Ежов Ефремов Жуков Заикин Иванов Карпов Качаев Ковалев Комогоров Кондрашин Коростелев Куманёв Нагуманов Найданов Никифоров Окунев Петров Плеханов Пономарев Поскачеев Предеин Редкий Сабиров Сидоров Сулима Таах Тимофеев Ткач Трубкин Черемных Чучва Шведов Шкляр Юрин",
      %w'Александр Алексей Анатолий Андрей Антон Вадим Виктор Виталий Владимир Всеволод Дмитрий Евгений Игорь Илья Константин Леонид Николай Олег Павел Руслан Сергей Станислав Тимур Эдуард Юрий',
      %w'Александрович Анатольевич Андреевич Борисович Валерьевич Викторович Владимирович Геннадьевич Иванович Игоревич Михайлович Николаевич Олегович Павлович Петрович Рашидович Сергеевич Степанович Юрьевич'
    ], :female => [
      %w"Архипова Барсукова Боронко Генералова Дубровина Ефимова Жукова Завьялова Иванова Кочурова Макарова Мокеева Нагуманова Николаева Петрова Платонова Самойлова Сесюнина Сидорова Сулима Таах Ткач Черемных Черноусова Чучва Шкляр",
      %w'Анна Антонина Валентина Екатерина Елена Ирина Людмила Мария Ольга Светлана Татьяна',
      %w'Александровна Анатольевна Андреевна Вадимовна Валерьевна Викторовна Владимировна Ивановна Николаевна Петровна Юрьевна'
    ]
  }

  BIG_HOUSES = [ 'Гоголя 1', 'Ленина 5', 'Пичугина 16' ]

  CELL_PREFIXES = [ 912, 919, 909, 905, 906, 961, 963, 922 ]

  DATA_FILE = Rails.root + 'tmp/billing_test_data.yml'

  class << self

    def fetch_users
      prepare_data
      @data
    end

    def user_info uid
      prepare_data
      @data[uid] || {}
    end

    def generate_test_data
      @data = []
      75.times do
        @data << generate_test_user
      end
      BIG_HOUSES.each do |h|
        (8+rand(10)).times do
          @data << generate_test_user(:address => "#{h}-#{1+rand(100)}")
        end
      end
      DATA_FILE.open 'w' do |f|
        f << @data.to_yaml
      end
      @data
    end

    private

    def prepare_data
      if !@data || @data.empty?
        @data = YAML::load(DATA_FILE.read) rescue nil
        @data ||= generate_test_data
      end
    end

    def generate_name
      sex = rand(100) < 26 ? :female : :male
      names = NAMES[sex].map(&:rand).join(' ')
    end

    def generate_phone
      if rand(100) < 30
        # 30% имеют городской номер
        "%02d-%02d-%02d" % [10+rand(90), rand(100), rand(100)]
      else
        # сотовый
        "8-%03d-%03d-%02d-%02d" % [CELL_PREFIXES.rand, rand(1000), rand(100), rand(100)]
      end
    end

    def generate_test_user h={}
      unless h[:user_id]
        @uid ||= 0
        @uid += 1
        h[:user_id] = @uid
      end

      bal    = (rand(200000)-100000) / 100.0
      bw     = rand(10)+1
      phones = [generate_phone]
      phones << generate_phone if rand(100)<30 # у 30% более одного телефона
      h.reverse_merge(
        :id          => h[:user_id],
        :lic_schet   => rand(99999999),
        :bal         => bal,
        :bal_red     => bal <= 0,
        :name        => generate_name,
        :address     => "#{STREETS.rand} #{rand(10)+1}-#{rand(100)+1}",
        :bandwidth   => bw*1024,
        :phones      => phones.join(', '),
        :tarif       => "Безлимитный-#{bw}М",
        :tarif_change_date => (Date.today - rand(100).days),
        :traf_report => {},
        :status => {
          "192.168.#{rand(256)}.#{rand(256)}" => {
            :name => (bal <= 0) ? 'Выключен' : 'Включен',
            :red  => (bal <= 0)
          }
        }
      )
    end
  end
end
