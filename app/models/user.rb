class User < ActiveRecord::Base
  include UserAuth

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

  belongs_to :created_by,   :class_name => 'User', :foreign_key => 'created_by_id'

  def can_manage_users?
    self.class.const_defined?('CAN_MANAGE') && self.class::CAN_MANAGE.any?
  end

  def type
    @attributes['type']
  end
end
