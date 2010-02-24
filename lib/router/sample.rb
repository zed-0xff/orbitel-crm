class Router::Sample < Router
  class << self
    # fetch ip info (vlan, mac address, etc)
    def ip_info ip
      r = {
        "interface"  => "vlan#{ip.to_s.split('.')[2]}",
        "status"     => 1
      }
      if rand < 0.25
        r['status'] = 0
      end
      if rand < 0.25
        r['error'] = ['WRONG MAC', 'no arping'].rand
      end
      r
    end

    # создать юзера на роутере
    def create_user! vlan, ip, comment
      false
    end
  end
end
