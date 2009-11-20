class Tickets::ConnectionTicketsController < ApplicationController
  before_filter :prepare_ticket
  before_filter :check_can_manage, :only => %w'vlan_edit update'

  def vlan
    render '_vlan', :layout => false
  end

  def vlan_edit
    render '_vlan_edit', :layout => false
  end

  def update
    h = params[:ticket]
    h.delete_if{ |k,v| k.to_s != 'vlan' }
    @ticket.update_attributes!(h)
    render '_vlan', :layout => false
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
