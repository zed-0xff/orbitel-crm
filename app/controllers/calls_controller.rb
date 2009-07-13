class CallsController < ApplicationController
  def index
    @calls = Radius::Call.all
  end
end
