class Tickets::ConnectionTicketsController < ApplicationController
  before_filter :prepare_ticket
  before_filter :check_can_manage, :except => %w'vlan ip'

  layout false

  def vlan;      render '_vlan'      ; end
  def vlan_edit; render '_vlan_edit' ; end
  def ip;        render '_ip'        ; end
  def ip_edit
    if @ticket.ip.blank?
      @ticket.ip = '192.168.'
    end
    render '_ip_edit'
  end

  def update
    h = params[:ticket]
    h.delete_if{ |k,v| !%w'vlan ip'.include?(k.to_s) }
    if h.keys == ['vlan']
      partial = '_vlan'
      comment = 
        if @ticket.vlan.blank?
          "назначил VLAN #{h['vlan']}"
        else
          "изменил VLAN с #{@ticket.vlan} на #{h['vlan']}"
        end
    elsif h.keys == ['ip']
      partial = '_ip'
      comment = 
        if @ticket.ip.blank?
          "назначил IP #{h['ip']}"
        else
          "изменил IP с #{@ticket.ip} на #{h['ip']}"
        end
    else
      raise "invalid keys"
    end

    if @ticket.update_attributes(h)
      TicketHistoryEntry.create!(
        :ticket         => @ticket,
        :user           => current_user,
        :comment        => comment,
        :system_message => true
      )
    else
      partial += '_edit'
    end

    render partial
  end

  def update_router_status
    @ticket.update_router_status!
    render '_router'
  end

  def create_at_router
    if @ticket.can_create_at_router?
      TicketHistoryEntry.create!(
        :ticket         => @ticket,
        :user           => current_user,
        :comment        => "создал абонента на роутере",
        :system_message => true
      )
      @ticket.create_at_router!
    end
    render '_router'
  end

  private

  def check_can_manage
    current_user.can_manage?:tickets
  end

  def prepare_ticket
    if params[:id]
      @ticket = Ticket.find params[:id].to_i
    end
    true
  end
end
