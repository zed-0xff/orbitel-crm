class Admin < User
  CAN_MANAGE = User::SUBCLASSES + %w'House'
end
