class TariffChange < Ticket
  before_create :set_dept

  validates_presence_of :date
  validates_inclusion_of :date, :in => (Time.now-1.month)..(Time.now+1.month)

  def title
    "смена ТП"
  end

  def set_dept
    self.dept = Dept[:admins]
  end

  # temporary
  def tariff
    nil
  end
end
