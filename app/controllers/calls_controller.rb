class CallsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => :find_customer_form

  def index
    @title = 'Звонки'

    @calls = Radius::Call.all(
      :order => 'acctstarttime DESC, acctstoptime DESC', 
      :limit => (params[:limit] || 50)
    )
    if @calls.any?
      h = {}
      @calls.each do |call|
        n = Phone.canonicalize(call.caller)
        h[n] ||= []
        h[n] << call
      end

      Phone.all(
        :conditions => {:number => h.keys},
        :include    => {:customer => {:house => :street}}
      ).each do |phone|
        h[phone.number].each do |call|
          call.customer = phone.customer
        end
        h.delete phone.number
      end

      # remaining unknown phones
      h.each do |n,calls|
        calls.each do |call|
          call.customer = nil
        end
      end
    end
  end

  def find_customer_form
    render :layout => false
  end

  # assign phone number to customer
  def assign_phone_number
    if !params[:customer].blank? && !params[:call_id].blank?
      call = Radius::Call.find_by_radacctid(params[:call_id].to_i)
      customer = Customer.find_by_name_and_address(params[:customer])
      if !call
        flash[:error] = 'Call not found'
      elsif !customer
        flash[:error] = 'Customer not found'
      else
        customer.phones.add call.caller
      end
    end
    redirect_to :action => :index
  end
end
