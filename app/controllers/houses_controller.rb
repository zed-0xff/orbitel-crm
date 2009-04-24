class HousesController < ApplicationController
  def check
    @title = 'Проверка дома'
    respond_to do |format|
      format.html
      format.js {
        render :js => 'alert(1)'
      }
    end
  end

  def new
  end

  def edit
  end

  def update
  end

end
