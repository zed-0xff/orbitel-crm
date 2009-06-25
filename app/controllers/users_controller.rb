class UsersController < ApplicationController
  before_filter :login_required
  before_filter :check_can_manage
  before_filter :prepare_user

  def index
    @users = User.find :all, :conditions => { :type => current_user.class::CAN_MANAGE }
  end

  def new
    @user = User.new :male => true
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

  def update
    type_key = @user.type.underscore
    params[type_key][:male] = 
      case params[type_key][:male]
        when 'true':
          true
        when 'false':
          false
        else
          nil
      end
    if @user.update_attributes(params[type_key])
      flash[:notice] = "Данные пользователя обновлены"
      if params[type_key][:type] != @user.type && current_user.is_a?(Admin)
        # only admins can change other user types
        @user.update_attribute :type, params[type_key][:type]
      end
      redirect_to users_path
    else
      render :action => 'edit'
    end
  end

  private

  def check_can_manage
    current_user.can_manage_users?
  end

  def prepare_user
    if params[:id]
      @user = User.find params[:id].to_i
    end
    true
  end
end
