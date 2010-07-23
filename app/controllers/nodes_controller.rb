class NodesController < ApplicationController
  before_filter :prepare_node
  helper :tickets

  def index
    @current_tickets = NodeHangTicket.current :order => 'created_at DESC'
    @last_tickets = NodeHangTicket.all :order => 'created_at DESC', :limit => 20
    t = NodeHangTicket.count(
      :group => 'node_id',
      :conditions => ["created_at >= ?",Date.today - 30.days]
    )
    @weak30nodes = []
    t.each do |node_id,cnt|
      @weak30nodes << [Node.find(node_id),cnt]
    end
    @weak30nodes = @weak30nodes.sort_by{ |t| -t[1] }

    t = NodeHangTicket.count(
      :group => 'node_id',
      :conditions => ["created_at >= ?",Date.today - 90.days]
    )
    @weak90nodes = []
    t.each do |node_id,cnt|
      @weak90nodes << [Node.find(node_id),cnt]
    end
    @weak90nodes = @weak90nodes.sort_by{ |t| -t[1] }
  end

  def show
    @customers = @node.customers.sort_by{ |c| c.flat.to_i }
    @subcustomers = []
    if @node.subnodes.any?
      @subcustomers = @customers.dup
      @subcustomers_count = @subcustomers.size
      get_subcustomers @node
    end
    if @subcustomers.any?
      if @subcustomers == @customers
        @subcustomers = []
      else
        @subcustomers = @subcustomers.sort_by{ |c| c.address }
      end
    end
    @tickets = @node.tickets :order => 'created_at DESC'
  end

  private

  def get_subcustomers node
    node.subnodes.each do |n|
      if @subcustomers_count >= 100
        @subcustomers_count += n.customers.count
      else
        @subcustomers += n.customers.sort_by{ |c| c.flat.to_i }
        @subcustomers_count = @subcustomers.size
      end
      if n.subnodes.any?
        get_subcustomers n
      end
    end
  end

  def prepare_node
    @node = Node.find(params[:id].to_i) if params[:id]
    true
  end
end
