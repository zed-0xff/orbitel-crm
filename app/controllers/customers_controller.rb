class CustomersController < ApplicationController
  helper :calls

  before_filter :prepare_customer

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
  end

  private

  def prepare_customer
    @customer = Customer.find(params[:id].to_i) if params[:id]
    true
  end
end
