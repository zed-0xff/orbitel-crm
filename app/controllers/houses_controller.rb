class HousesController < ApplicationController
  before_filter :prepare_house
  
  def index
    if params[:street] || params[:number]
      conditions = ["TRUE"]
      unless params[:street].blank?
        conditions[0] << " AND name LIKE ?"
        conditions    << "%#{params[:street].strip}%"
      end
      unless params[:number].blank?
        conditions[0] << " AND number LIKE ?"
        conditions    << "#{params[:number].strip}%"
      end
      @houses = House.paginate(
        :page       => params[:page], 
        :order      => "streets.name, convert(number,unsigned), number",
        :include    => :street,
        :joins      => 'LEFT JOIN streets ON houses.street_id = streets.id',
        :conditions => conditions
      )
    else
      @houses = House.paginate :page => params[:page], :order => "created_at DESC"
    end
  end

  def check
    @title = 'Проверка дома'

    coords = nil
    error  = nil
    house  = nil
    if params[:house] && params[:house][:street] && params[:house][:number]
      begin
        street = params[:house][:street]
        number = params[:house][:number]
        house  = House.find_or_initialize_by_street_and_number(street, number)
        coords = house.coords || begin
          @@dgis ||= DoubleGis.new
          dgis_coords = @@dgis.house_coords(street, number)
          if dgis_coords && !house.new_record?
            # house IS NOT new, but has no saved coords. save them.
            house.update_attributes :x => dgis_coords[0], :y => dgis_coords[1]
          end
          dgis_coords
        end
        error = "Невозможно определить координаты дома" unless coords
      rescue Exception => ex
        logger.error "#{ex.inspect} while ran DoubleGis#house_coords(#{street.inspect}, #{number.inspect})"
        logger.error ex.backtrace.join("\n")
        error = ex.to_s
      end
    end

    respond_to do |format|
      format.html
      format.js {
        render :update do |page|
          page.replace_html('result', :partial => 'house_status', 
            :locals => {:error => error, :house => house}
          )
          page.visual_effect :highlight, 'result'
          if coords
            page << "marker.lonlat.lon = #{coords[0]};"
            page << "marker.lonlat.lat = #{-coords[1]};"
            page << "markers.drawMarker(marker);"
            page << "map.setCenter( new OpenLayers.LonLat( #{coords[0]}, #{-coords[1]} ), 5 );"
            #page << "map.panTo( new OpenLayers.LonLat( #{coords[0]}, #{-coords[1]} ));"
          end
        end
      }
    end
  end

  def new
    @house = House.new
  end

  def create
    @house = House.create params[:house]
    if @house.valid?
      redirect_to houses_path
    else
      render :action => 'new'
    end
  end

  def update
    if params[:house][:street]
      params[:house][:street] = Street.find_or_initialize_by_name params[:house][:street]
    end
    if @house.update_attributes(params[:house])
      flash[:notice] = "Данные дома обновлены"
      redirect_to houses_path
    else
      render :action => 'edit'
    end
  end

  private

  def prepare_house
    if params[:id]
      @house = House.find params[:id].to_i
    end
    true
  end

end
