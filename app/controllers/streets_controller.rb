class StreetsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:auto_complete]

  def auto_complete
    method = 'name'

    find_options = {
      :conditions => [ "LOWER(#{method}) LIKE ?", '%' + find_street(params).downcase + '%' ],
      :order => "#{method} ASC",
      :limit => 10 }

    @items = Street.find(:all, find_options)

    render :inline => "<%= auto_complete_result @items, '#{method}' %>"
  end

  private

  def find_street h
    return h[:street] if h[:street] && h[:street].is_a?(String)
    h.values.each do |v|
      r = v.is_a?(Hash) && find_street(v)
      return r if r
    end
    nil
  end
end
