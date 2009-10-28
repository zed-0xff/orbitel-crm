require 'digest/sha1'

module UserAuth
  def self.included(recipient)
    recipient.extend(ModelClassMethods)
    recipient.class_eval do
      include Authentication
      include Authentication::ByPassword
      include Authentication::ByCookieToken

      # HACK HACK HACK -- how to do attr_accessible from here?
      # prevents a user from submitting a crafted form that bypasses activation
      # anything else you want your user to change should be added here.
      attr_accessible :login, :email, :name, :password, :password_confirmation, :male, :dept_id, :deleted

      include ModelInstanceMethods
    end
  end

  module ModelClassMethods
    # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
    #
    # uff.  this is really an authorization, not authentication routine.  
    # We really need a Dispatch Chain here or something.
    # This will also let us return a human error message.
    #
    def authenticate(login, password)
      return nil if login.blank? || password.blank?
      u = find_by_login(login.downcase) # need to get the salt
      u && u.authenticated?(password) ? u : nil
    end
  end

  module ModelInstanceMethods
    def login=(value)
      write_attribute :login, (value ? value.downcase : nil)
    end

    def email=(value)
      write_attribute :email, (value ? value.downcase : nil)
    end
  end
end
