class User < ActiveRecord::Base
  include UserAuth

  SUBCLASSES = %w'Manager Technician Admin SuperManager VirtualUser Director'

  has_many :ticket_history_entries
  has_many :vacations

  belongs_to :dept

  before_validation :fix_email

  validates_presence_of     :type,     :if => Proc.new{ |u| u.class == User }

  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message
  validates_uniqueness_of   :login,    :unless => Proc.new{ |u| u.errors.on(:email) || u.errors.on(:login) }

  validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :name,     :maximum => 100

  #validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100, :allow_nil => true
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message, :allow_nil => true
  validates_uniqueness_of   :email,    :unless => Proc.new{ |u| u.errors.on(:email) || u.errors.on(:login) }, :allow_nil => true

  belongs_to :created_by,   :class_name => 'User'

  validates_inclusion_of    :type, :in => SUBCLASSES

  def can_manage_users?
    self.class.const_defined?('CAN_MANAGE') && 
      self.class::CAN_MANAGE.any?{ |entity| SUBCLASSES.include?(entity) }
  end

  def can_manage? what
    self.is_a?(Admin) || (
      self.class.const_defined?('CAN_MANAGE') && 
        self.class::CAN_MANAGE.include?(what.to_s.singularize.humanize)
    )
  end

  def can_manage_any_of? *whats
    whats.any?{ |what| can_manage?(what) }
  end

  # сокращаем список моделей до списка первых букв - для яваскрипта
  def can_manages_for_js
    %w'Customer House User'.map do |what|
      can_manage?(what) ? what[0..0] : nil
    end.compact.join.downcase
  end

  def type
    @attributes['type']
  end

  def female?
    male.nil? ? nil : !male
  end

  private

  def fix_email
    self.email = nil if self.email.blank?
  end
end
