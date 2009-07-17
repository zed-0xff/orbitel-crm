class CallsController < ApplicationController
  def index
    @calls = Radius::Call.all(
      :order => 'acctstarttime DESC, acctstoptime DESC', 
      :limit => (params[:limit] || 50)
    )
  end
end
