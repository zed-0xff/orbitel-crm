class TicketsController < ApplicationController
  auto_complete_for :street, :name
  skip_before_filter :verify_authenticity_token, :only => [:auto_complete_for_street_name]

  before_filter :check_type, :only => :create

  def new_request
    @ticket = ConnectionPossibilityRequest.new
  end

  def create
    klass  = Kernel.const_get(params[:ticket][:type])
    ticket = klass.new( params[:ticket] )
  end

  def edit
  end

  def update
  end

  
  private

  def check_type
    params[:ticket] && %w'ConnectionPossibilityRequest'.include?(params[:ticket][:type])
  end
end
