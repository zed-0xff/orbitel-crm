class CallsController < ApplicationController
  def index
    @calls = Radius::Call.all :order => 'acctstarttime DESC, acctstoptime DESC', :limit => 50
  end
end
