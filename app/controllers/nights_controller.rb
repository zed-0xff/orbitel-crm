class NightsController < ApplicationController
  def index
    @start_date = Date.civil( Date.today.year, Date.today.mon )
    @end_date   = Date.civil( Date.today.year, Date.today.mon, -1 )
  end
end
