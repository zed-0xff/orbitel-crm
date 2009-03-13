require 'user_auth'

class User < ActiveRecord::Base
  include UserAuth
end
