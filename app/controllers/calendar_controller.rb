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

    @totals = Hash.new(0)
    @dobjects.values.each do |day|
      day.each do |k,v|
        @totals[k] += v.is_a?(Array) ? v.size : v
      end
    end
  end

  private

  def collect tag, opts = {}
    klass = opts[:class] || tag.to_s.capitalize.singularize.constantize
    opts[:date_field] ||= 'created_at'
    klass.all(
      :conditions => { opts[:date_field] => @start_date.to_time..((@end_date.to_date+1).to_time-1) },
      :order      => opts[:date_field]
    ).each do |obj|
      # skip houses that have no customers
      next if obj.is_a?(House) && !obj.customers.first
      @dobjects[ obj.created_at.to_date ][tag] << obj
    end
  end

  def count tag, opts = {}
    klass = opts[:class] || tag.to_s.capitalize.singularize.constantize
    opts[:date_field] ||= 'created_at'
    klass.count(
      :conditions => { opts[:date_field] => @start_date.to_time..((@end_date.to_date+1).to_time-1) }.merge(opts[:conditions] || {}),
      :group      => "DATE(#{opts[:date_field]})",
      :order      => opts[:date_field]
    ).each do |date,cnt|
      @dobjects[date.to_date][tag] = cnt
    end
  end
end
