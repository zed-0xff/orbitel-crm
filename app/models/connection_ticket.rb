class ConnectionTicket < Ticket
  before_create :set_dept
  serialize :custom_info

  def title
    "Подключение"
  end

  def set_dept
    self.dept = Dept[:prorabs]
  end

  %w'vlan ip tariff_name'.each do |m|
    class_eval %Q<
      def #{m}
        custom_info.try(:[], :#{m})
      end
      def #{m}= value
        self.custom_info ||= {}
        self.custom_info[:#{m}] = value
      end
    >
  end

  private

  def after_find
    self.custom_info ||= {}
  end
  alias_method :after_initialize, :after_find
end
