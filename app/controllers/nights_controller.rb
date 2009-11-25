class NightsController < ApplicationController
  before_filter :check_access

  def index
    @year  = (params[:year] || Date.today.year).to_i
    @month = (params[:month] || Date.today.mon).to_i

    @start_date = Date.civil( @year, @month )
    @end_date   = Date.civil( @year, @month, -1 )
    @vacations_by_user_id = {}
    Vacation.for_month( @year, @month ).each do |vacation|
      @vacations_by_user_id[vacation.user_id] ||= []
      @vacations_by_user_id[vacation.user_id] << vacation
    end
    all_users = {}
    User.all.each{ |u| all_users[u.id] = u }
    order = Settings['nights.order'].to_a
    @users = []
    order.each do |uid|
      @users << all_users.delete(uid) if all_users[uid]
    end
    @users += all_users.values

    @nights = Settings["nights.#{@year}.#{@month}"] || {}

    # show deleted users if they have any nights in current month
    # hide otherwise
    @users.delete_if{ |u| u.deleted? && !@nights.values.include?(u.id) } if @nights.any?
    @users.delete_if{ |u| u.class == User && !@nights.values.include?(u.id) } if @nights.any?

    if @readonly
      @users.delete_if{ |u| !@nights.values.include?(u.id) } if @nights.any?
    else
      prev_month = @month - 1
      prev_year  = @year
      if prev_month == 0
        prev_year -= 1
        prev_month = 12
      end
      prev_nights    = Settings["nights.#{prev_year}.#{prev_month}"] || {}
      prev_month_end = Date.civil( prev_year, prev_month, -1 )
      @prev_month_last = {}
      prev_nights.sort_by{ |dt,uid| dt }.each do |dt,uid|
        @prev_month_last[uid] = (prev_month_end - dt) + 1
      end
    end
  end

  def add_vacation
    if @readonly
      flash[:error] = 'Нет доступа'
      redirect_to '/nights'
      return
    end

    Vacation.create!(
      :user       => User.find(params[:user_id]),
      :start_date => params[:start_date],
      :end_date   => params[:end_date]
    )
    flash[:notice] = "Отпуск добавлен"
    redirect_to '/nights'
  end

  def save_param
    if @readonly
      flash[:error] = 'Нет доступа'
      redirect_to '/nights'
      return
    end

    if params['order'] && params['nights'] && params['month'] && params['year']
      Settings['nights.order'] = params['order'].split(',').map(&:to_i)

      unless params['nights'].blank?
        year   = params['year'].to_i
        month  = params['month'].to_i
        nights = {}
        params['nights'].split(',')[1..-1].each_with_index{ |uid,day|
          next if uid.blank?
          nights[ Date.civil(year, month, day+1) ] = uid.to_i;
        }
        Settings["nights.#{year}.#{month}"] = nights
      end

      render :update do |page|
        page['status-info'].innerHTML = 'Сохранено'
        page.visual_effect :highlight, 'status-info', :duration => 1
      end
    else 
      render :update do |page|
        page['status-info'].innerHTML = 'Ошибка!'
        page.visual_effect :highlight, 'status-info', :duration => 1.5, 
          :startcolor => '#ff0000'
      end
    end
  end

  private

  def check_access
    @readonly = true
    @readonly = false if current_user && Settings['nights.managed_by'].to_a.include?(current_user.id)
    true
  end
end
