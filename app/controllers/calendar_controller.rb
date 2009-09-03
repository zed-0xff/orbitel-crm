class CalendarController < ApplicationController
  def index
    dt = Date.today
    if params[:pos]
      dt += params[:pos].to_i.months
    end

    @start_date = Date.civil(dt.year, dt.month)
    @end_date   = Date.civil(dt.year, dt.month, -1)
    @dobjects   = Hash.new{ |k,v| k[v] = ActiveSupport::OrderedHash.new{ |k1,v1| k1[v1] = [] } }

    collect :houses
    collect :customers
    count   :tickets
    count   :calls, :date_field => 'start_time'
    count   :closed_tickets, :class => Ticket, :date_field => 'closed_at'
    count   :reopened_tickets, :class => TicketHistoryEntry, :conditions => {:new_status => Ticket::ST_REOPENED}
  end

  private

  def collect tag, opts = {}
    klass = opts[:class] || tag.to_s.capitalize.singularize.constantize
    opts[:date_field] ||= 'created_at'
    klass.all(
      :conditions => { opts[:date_field] => @start_date..@end_date },
      :order      => opts[:date_field]
    ).each do |obj|
      @dobjects[ obj.created_at.to_date ][tag] << obj
    end
  end

  def count tag, opts = {}
    klass = opts[:class] || tag.to_s.capitalize.singularize.constantize
    opts[:date_field] ||= 'created_at'
    klass.count(
      :conditions => { opts[:date_field] => @start_date..@end_date }.merge(opts[:conditions] || {}),
      :group      => "DATE(#{opts[:date_field]})",
      :order      => opts[:date_field]
    ).each do |date,cnt|
      @dobjects[date.to_date][tag] = cnt
    end
  end
end
