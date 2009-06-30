# an user that can NOT login
class VirtualUser < User
  def authenticated? *args
    false
  end
end
