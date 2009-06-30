class NightsController < ApplicationController
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
  end

  def add_vacation
    Vacation.create!(
      :user       => User.find(params[:user_id]),
      :start_date => params[:start_date],
      :end_date   => params[:end_date]
    )
    flash[:notice] = "Отпуск добавлен"
    redirect_to '/nights'
  end

  def save_param
    if params['order'] && params['nights'] && params['month'] && params['year']
      Settings['nights.order'] = params['order'].split(',').map(&:to_i)

      year   = params['year'].to_i
      month  = params['month'].to_i
      nights = {}
      params['nights'].split(',')[1..-1].each_with_index{ |uid,day|
        next if uid.blank?
        nights[ Date.civil(year, month, day+1) ] = uid.to_i;
      }
      Settings["nights.#{year}.#{month}"] = nights

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
end
