# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  skip_before_filter :login_required, :only => %w'new create'
  before_filter :localizate
  
  def localizate
    I18n.locale = params[:locale] || I18n.default_locale
  end

  # render new.rhtml
  def new
  end

  def create
    logout_keeping_session!
    user = User.authenticate(params[:login], params[:password])
    if user
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_user = user
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      cookies[:can_manage] = { :value => user.can_manages_for_js, :expires => 1.year.from_now }
      redirect_back_or_default('/')
      #flash[:notice] = I18n.t(:logged_in)
    else
      note_failed_signin
      @login       = params[:login]
      @remember_me = params[:remember_me]
      render :action => 'new'
    end
  end

  def destroy
    cookies.delete :can_manage
    logout_killing_session!
    flash[:notice] = "Вы вышли из системы"
    redirect_back_or_default('/')
  end

protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Вход не выполнен"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
