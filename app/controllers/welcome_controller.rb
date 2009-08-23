class WelcomeController < ApplicationController
  helper :tickets
  skip_before_filter :login_required

  def index
    if logged_in?
      @history = TicketHistoryEntry.paginate(
        :page     => params[:page],
        :per_page => params[:per_page] || 30,
        :order    => "created_at DESC"
      )
    end
  end
end
