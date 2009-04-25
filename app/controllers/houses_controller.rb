class HousesController < ApplicationController
  def check
    @title = 'Проверка дома'

    coords = nil
    html   = nil
    if params[:house] && params[:house][:street] && params[:house][:number]
      begin
        street = params[:house][:street]
        number = params[:house][:number]
        if coords = DoubleGis.new.house_coords(street, number)
          html = coords.inspect
        else
          html = "<font color='red'><b>Невозможно определить координаты</b></font>"
        end
      rescue Exception => ex
        html = "<font color='red'><b>#{ex.to_s}</b></font>"
      end
    end

    respond_to do |format|
      format.html
      format.js {
        render :update do |page|
          page.replace_html 'result', html
          page.visual_effect :highlight, 'result'
          if coords
            page << "map.setCenter(new OpenLayers.LonLat(#{coords[0]}, #{-coords[1]},5));"
          end
        end
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
