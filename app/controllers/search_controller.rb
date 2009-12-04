class SearchController < ApplicationController
  def index
    @q = params[:q]
    @title = @q.inspect

    @customers = Customer.all( 
      :conditions => ["name LIKE ?", "%#@q%"],
      :limit      => 20
    )

    @streets = Street.all( 
      :conditions => ["name LIKE ?", "%#@q%"],
      :limit      => 20
    )

    q = @q.strip.split(/\s+/)
    if q.size > 1 && q.last[/[0-9]/]
      street = q[0..-2].join(' ')
      number = q.last
     
      conditions = ["TRUE"]
      unless street.blank?
        conditions[0] << " AND name LIKE ?"
        conditions    << "%#{street.strip}%"
      end
      unless number.blank?
        conditions[0] << " AND number LIKE ?"
        conditions    << "#{number.strip}%"
      end
      @houses = House.all(
        :order      => "streets.name, convert(number,unsigned), number",
        :include    => :street,
        :joins      => 'LEFT JOIN streets ON houses.street_id = streets.id',
        :conditions => conditions,
        :limit      => 20
      )
    end
  end

end
