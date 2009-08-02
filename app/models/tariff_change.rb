class TariffChange < Ticket
  before_create :set_dept

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
