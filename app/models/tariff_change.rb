class TariffChange < Ticket
  before_create :set_dept

  validates_presence_of :date,   :message => '^Дата не указана'
  validates_presence_of :tariff, :message => '^Тариф не выбран'
  validates_presence_of :contact_name, :message => "^Абонент не указан"

  def validate_on_create
    if self.date
      if self.date < (Date.today-1.month)
        self.errors.add :date, "^Дата не может быть раньше одного месяца от текущей" 
      end
      if self.date > (Date.today+1.month)
        self.errors.add :date, "^Дата не может быть позже одного месяца от текущей" 
      end
    end
  end

  def title
    "смена ТП c #{date}"
  end

  def set_dept
    self.dept = Dept[:admins]
  end

  def tariff= value
    self.custom_info = value.to_s
  end

  # find tariff by its external_id
  def tariff_ext_id= value
    t = Tariff.find_by_external_id(value.to_i)
    self.tariff = t.id if t
  end

  def tariff
    if self.custom_info.to_s =~ /^\d+$/
      custom_info.to_i
    else
      custom_info
    end
  end

  def tariff_name
    if (t = tariff).is_a?(Numeric)
      Tariff.find_by_id(t).try(:name) || "?? #{t} ??"
    else
      t
    end
  end
end
