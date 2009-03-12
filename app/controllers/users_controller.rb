class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem and localizate in Application Controller instead
  include AuthenticatedSystem
  
  before_filter :localizate
  
  def localizate
    I18n.locale = params[:locale] || I18n.default_locale
  end

  # render new.rhtml
  def new
    @user = User.new
  end
 
  def create
    logout_keeping_session!
    @user = User.new(params[:user])
    success = @user && @user.save
    if success && @user.errors.empty?
            # Protects against session fixation attacks, causes request forgery
      # protection if visitor resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset session
      self.current_user = @user # !! now logged in
      redirect_back_or_default('/')
              flash[:notice] = I18n.t(:signup_complete)
      
    else
      flash[:error]  = I18n.t(:signup_problem)
      render :action => 'new'
    end
  end
end
