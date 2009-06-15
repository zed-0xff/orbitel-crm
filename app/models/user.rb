class User < ActiveRecord::Base
  include UserAuth

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

  validates_inclusion_of    :type, :in => %w'Manager Technician Admin SuperManager'

  def can_manage_users?
    self.class.const_defined?('CAN_MANAGE') && 
      self.class::CAN_MANAGE.any?{ |entity| %w'User Manager Technician SuperManager'.include?(entity) }
  end

  def can_manage? what
    self.class.const_defined?('CAN_MANAGE') && 
      self.class::CAN_MANAGE.include?(what.to_s.singularize.humanize)
  end

  def type
    @attributes['type']
  end

  private

  def fix_email
    self.email = nil if self.email.blank?
  end
end
