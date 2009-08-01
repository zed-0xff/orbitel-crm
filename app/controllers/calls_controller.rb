class CallsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => %w'find_customer_form ajax'

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

  def ajax
    new_active_ids = []
    active_ids = params[:active].split(':').map(&:to_i).uniq
    active_ids.delete(0)
    active_calls = active_ids.any? ? Radius::Call.all(:conditions => { :radacctid => active_ids }) : []
    new_calls = Radius::Call.all(
      :conditions => [ 'radacctid > ?', params[:last].to_i],
      :order => "acctstarttime DESC, acctstoptime DESC"
    )

    render :update do |page|
      active_calls.each do |call|
        page.replace_html "dur#{call.id}", distance_of_time_in_images(call)
        page.visual_effect :highlight, "dur#{call.id}"
        new_active_ids << call.id unless call.ended?
      end
      new_calls.each do |call|
        page.insert_html :before, "tr#{params[:last]}", :partial => 'call', :locals => { :call => call }
        page.visual_effect :highlight, "tr#{call.id}"
        new_active_ids << call.id unless call.ended?
        page.assign 'last_call_id', [params[:last].to_i, new_calls.map(&:id).max].max
      end
      page.assign 'active_calls', new_active_ids.uniq
    end
  end
end
