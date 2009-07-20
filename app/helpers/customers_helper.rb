module CustomersHelper
  TRAF_TYPES = {
    :in_sat   => 'входящий',
    :inet_out => 'исходящий',
    :local    => 'локальный'
  }

  def traf_type type
    TRAF_TYPES[type] || type
  end
end
