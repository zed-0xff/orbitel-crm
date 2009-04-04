class TicketsController < ApplicationController
  auto_complete_for :street, :name
  skip_before_filter :verify_authenticity_token, :only => [:auto_complete_for_street_name]

  def new_request
    @ticket = ConnectionPossibilityRequest.new
  end

  def create
  end

  def edit
  end

  def update
  end

end
