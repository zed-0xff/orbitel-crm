class ConnectionPossibilityRequest < Ticket
  before_create :set_dept

  def title
    "Запрос на возможность подключения"
  end

  def set_dept
    self.dept = Dept[:prorabs]
  end
end
