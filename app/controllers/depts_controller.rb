class DeptsController < ApplicationController
  before_filter :login_required
  before_filter :check_can_manage
  before_filter :prepare_dept

  def index
    @depts = Dept.all
  end

  def new
    @dept = Dept.new
  end

  def create
    @dept = Dept.new params[:dept]
    if @dept.save
      flash[:notice] = 'Dept created successfully'
      redirect_to depts_path
    else
      render :action => :new
    end
  end

  def update
    if @dept.update_attributes(params[:dept])
      flash[:notice] = "Данные отдела обновлены"
      redirect_to depts_path
    else
      render :action => 'edit'
    end
  end

  private

  def check_can_manage
    current_user.can_manage?:depts
  end

  def prepare_dept
    if params[:id]
      @dept = Dept.find params[:id].to_i
    end
    true
  end
end
