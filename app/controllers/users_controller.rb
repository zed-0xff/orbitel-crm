class UsersController < ApplicationController
  before_filter :login_required
  before_filter :check_can_manage

  def index
    @users = User.find :all, :conditions => { :type => current_user.class::CAN_MANAGE }
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new params[:user]
    @user.type = params[:user][:type]
    @user.email = nil if @user.email.blank?
    @user.created_by = current_user

    if @user.save
      flash[:notice] = 'User created successfully'
      redirect_to users_path
    else
      render :action => :new
    end
  end

  private

  def check_can_manage
    current_user.can_manage_users?
  end
end
