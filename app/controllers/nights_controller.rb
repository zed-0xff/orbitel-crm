class NightsController < ApplicationController
  def index
    @start_date = Date.civil( Date.today.year, Date.today.mon )
    @end_date   = Date.civil( Date.today.year, Date.today.mon, -1 )
    @users      = User.all
    @vacations_by_user_id = {}
    Vacation.for_month( Date.today.year, Date.today.mon ).each do |vacation|
      @vacations_by_user_id[vacation.user_id] ||= []
      @vacations_by_user_id[vacation.user_id] << vacation
    end
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
end
