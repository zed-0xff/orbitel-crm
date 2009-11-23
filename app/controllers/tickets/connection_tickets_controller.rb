class Tickets::ConnectionTicketsController < ApplicationController
  before_filter :prepare_ticket
  before_filter :check_can_manage, :only => %w'vlan_edit update'

  def vlan;      render '_vlan',      :layout => false; end
  def vlan_edit; render '_vlan_edit', :layout => false; end
  def ip;        render '_ip',        :layout => false; end
  def ip_edit
    if @ticket.ip.blank?
      @ticket.ip = '192.168.'
    end
    render '_ip_edit',   :layout => false
  end

  def update
    h = params[:ticket]
    h.delete_if{ |k,v| !%w'vlan ip'.include?(k.to_s) }
    partial = 
      if h.keys == ['vlan']
        '_vlan'
      elsif h.keys == ['ip']
        '_ip'
      else
        raise "invalid keys"
      end
    unless @ticket.update_attributes(h)
      partial += '_edit'
    end
    render partial, :layout => false
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
