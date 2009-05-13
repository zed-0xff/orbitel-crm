class Admin < User
  CAN_MANAGE = %w'Admin User Manager SuperManager Technician House'
end
