class NodeHangTicket < Ticket
  belongs_to :node
  validates_presence_of :node

  def title
    "Зависание узла: " + (self.node.try(:name) || '')
  end

  def before_create
    self.priority = PRIORITY_HIGH
  end
end
