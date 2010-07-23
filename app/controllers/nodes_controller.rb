class NodesController < ApplicationController
  before_filter :prepare_node

  def index
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
