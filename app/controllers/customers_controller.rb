class CustomersController < ApplicationController
  helper :calls

  before_filter :prepare_customer

  BILLING_INFO_CACHE_PERIOD = 4.hours

  def index
    conditions =
      if params[:filter].blank?
        nil
      else
        ["name LIKE ?", "%#{params[:filter]}%"]
      end

    @customers = Customer.paginate(
      :order      => 'name',
      :page       => params[:page],
      :per_page   => 50,
      :conditions => conditions,
      :include    => {:house => :street}
    )
  end

  def show
    @title = @customer.name
    @calls = @customer.calls
    @binfo = read_fragment("customers/#{@customer.id}/billing_info")
    if @binfo && @binfo =~ /- TIMESTAMP:(\d+) -/ && ($1.to_i-Time.now.to_i).abs > BILLING_INFO_CACHE_PERIOD
      expire_fragment("customers/#{@customer.id}/billing_info")
      @binfo = nil
    end
  end

  KRUS_MAP = {
    :bal       => 'баланс',
    :bal_red   => nil,
    :tarif     => 'тариф',
    :tarif_red => nil,
    :name      => 'имя',
    :lic_schet => 'лиц.счет'
  }

  def billing_info
    expire_fragment("customers/#{@customer.id}/billing_info")
    @info = Krus.user_info(@customer.krus_user_id)
    if v = @info[:traf_report]
      v.delete(:in_sat_day) if v[:in_sat] == v[:in_sat_day]
      v.delete :user_id
    end
    render :layout => false
  end

  private

  def prepare_customer
    @customer = Customer.find(params[:id].to_i) if params[:id]
    true
  end
end
