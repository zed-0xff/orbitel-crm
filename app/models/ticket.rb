class Ticket < ActiveRecord::Base
  belongs_to :house
  belongs_to :created_by, :class_name => 'User'
  belongs_to :assignee,   :class_name => 'User'
  belongs_to :dept
  belongs_to :customer

  has_many :ticket_history_entries, :order => 'created_at DESC'
  alias :history :ticket_history_entries

  validates_associated  :house, :message => '^Ошибки в адресе подключения'
  validates_presence_of :house, :message => '^Абонент не указан', :if => Proc.new{ |t| t.class == Ticket }
  validates_presence_of :title, :message => '^Не указана суть проблемы'

  def before_validation
    if self.customer && !self.contact_name && !self.house
      self.contact_name = self.customer.name
      self.contact_info = self.customer.phones.map(&:humanize).join(', ') if self.customer.phones
      self.house        = self.customer.house
      self.flat         = self.customer.flat
    end
  end

  accepts_nested_attributes_for :house

  default_scope :order => 'created_at'

  named_scope :for_user, lambda{ |user|
    { :conditions => ["dept_id IS NULL OR dept_id = ? OR assignee_id = ?", user.dept, user] }
  }

  named_scope :for_dept, lambda{ |dept|
    { :conditions => { :dept_id => dept }}
  }

  named_scope :created_at, lambda{ |date|
    { :conditions => { :created_at => (date.to_time)..((date+1).to_time - 1) }}
  }

  named_scope :closed_at, lambda{ |date|
    { :conditions => { :closed_at => (date.to_time)..((date+1).to_time - 1) }}
  }

  named_scope :reopened_at, lambda{ |date|
    { 
      :joins      => :ticket_history_entries,
      :conditions => { 
        :ticket_history_entries => {
          :created_at => (date.to_time)..((date+1).to_time - 1),
          :new_status => ST_REOPENED
        }
      }
    }
  }

  after_create :log_new_ticket

  after_create  :update_caches
  after_destroy :update_caches
  after_update  :update_caches

  CONTACT_TYPE_UR  = 1
  CONTACT_TYPE_FIZ = 2

  PRIORITY_HIGHEST = 10
  PRIORITY_HIGH    = 5
  PRIORITY_NORMAL  = 0
  PRIORITY_LOW     = -5
  PRIORITY_LOWEST  = -10

  PRIORITIES = [10, 5, 0, -5, -10]

  # statuses
  ST_NEW       = 0
  ST_ACCEPTED  = 5
  ST_CLOSED    = 10
  ST_REOPENED  = 15

  STATUSES = [0, 5, 10, 15]

  COND_CURRENT = ["status != ?", Ticket::ST_CLOSED]
  COND_NEW     = { :status => [Ticket::ST_NEW, Ticket::ST_REOPENED] }

  named_scope :current, { :conditions => COND_CURRENT }

  # create a house if needed, or find an existing by its attributes
  def initialize *args
    if args.first.is_a?(Hash) && (house_attrs=(args.first[:house] || args.first[:house_attributes])).is_a?(Hash)
      street = if house_attrs[:street_id]
        Street.find house_attrs[:street_id]
      elsif house_attrs[:street]
        Street.find_by_name house_attrs[:street]
      else
        nil
      end

      house = if street
        House.find_or_initialize_by_street_id_and_number(
          street.id,
          house_attrs[:number]
        )
      else
        House.new(
          :number => house_attrs[:number]
        )
      end

      args[0] = args.first.dup
      args.first[:house] = house
      args.first.delete :house_attributes
    end
    super(*args)
  end

  def address
    if house
      "#{house.street.try(:name)} #{house.number}" + (flat.blank? ? '' : "-#{flat}")
    else
      nil
    end
  end

  # assign customer by its external id
  def customer_ext_id= ext_id
    self.customer = Customer.find_by_external_id ext_id
  end

  def change_status! new_status, options = {}
    if options[:user] 
      if options[:assign]
        self.assignee = options[:user]
      end
      self.history << TicketHistoryEntry.new(
        :user       => options[:user],
        :old_status => self.status,
        :new_status => new_status,
        :comment    => options[:comment]
      )
    end
    self.closed_at = Time.now if new_status == ST_CLOSED && !self.closed?
    self.status    = new_status
    self.save!
  end

  # target can be Dept or User
  def redirect! target, options = {}
    if target.is_a?(Dept)
      self.dept = target
      self.history << TicketHistoryEntry.new(
        :user       => options[:user],
        :comment    => "переадресовал заявку в отдел \"#{target.name}\""
      )
      # unassign ticket if current assignee is not from dept to which ticket is redirected
      if self.assignee && self.assignee.dept != target
        self.assignee = nil
      end
      self.save!
    elsif target.is_a?(User)
      self.assignee = target
      self.history << TicketHistoryEntry.new(
        :user       => options[:user],
        :comment    => "переадресовал заявку пользователю \"#{target.name}\""
      )
      self.save!
    else
      raise "Invalid redirect target: #{target.inspect}"
    end
  end

  def change_priority! new_prio, options = {}
    return false if self.priority == new_prio
    self.priority = new_prio
    self.history << TicketHistoryEntry.new(
      :user       => options[:user],
      :comment    => "изменил приоритет заявки на \"#{Ticket.priority_desc(new_prio)}\""
    )
    self.save!
  end

  def closed?
    self.status == ST_CLOSED
  end

  def self.priority_desc pr
    case pr
      when Ticket::PRIORITY_HIGHEST
        "Наивысший"
      when Ticket::PRIORITY_HIGH
        "Высокий"
      when Ticket::PRIORITY_NORMAL
        "Нормальный"
      when Ticket::PRIORITY_LOW
        "Низкий"
      when Ticket::PRIORITY_LOWEST
        "Низший"
      else
        "?? #{pr} ??"
    end
  end

  private

  def log_new_ticket
    self.history.create!(
      :user => self.created_by,
      :old_status => nil,
      :new_status => self.status
    ) if self.created_by
  end

  def update_caches
    Rails.cache.delete 'ticket.counts'
    if self.customer_id
      # customer status icons
      # see app/helpers/application_helper.rb : link_to_customer & customer_link_class
      Rails.cache.delete "customer.#{self.customer_id}.status-icon"
    end
  end
end
