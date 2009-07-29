class CallsController < ApplicationController
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
end
