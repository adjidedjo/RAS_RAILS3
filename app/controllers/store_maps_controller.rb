class StoreMapsController < ApplicationController
  # GET /store_maps
  # GET /store_maps.json
  def index
    @store_maps = StoreMap.all.to_gmaps4rails do |city, marker|

			marker.infowindow render_to_string(:partial => "/store_maps/infowindow", :locals => { :city => city})
		  marker.title "#{city.address}"
		  marker.picture({:width => 32,
                    :height => 32})
    end
  end

  # GET /store_maps/1
  # GET /store_maps/1.json
  def show
    @store_map = StoreMap.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @store_map }
    end
  end

  # GET /store_maps/new
  # GET /store_maps/new.json
  def new
    @store_map = StoreMap.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @store_map }
    end
  end

  # GET /store_maps/1/edit
  def edit
    @store_map = StoreMap.find(params[:id])
  end

  # POST /store_maps
  # POST /store_maps.json
  def create
    @store_map = StoreMap.new(params[:store_map])

    respond_to do |format|
      if @store_map.save
        format.html { redirect_to @store_map, notice: 'Store map was successfully created.' }
        format.json { render json: @store_map, status: :created, location: @store_map }
      else
        format.html { render action: "new" }
        format.json { render json: @store_map.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /store_maps/1
  # PUT /store_maps/1.json
  def update
    @store_map = StoreMap.find(params[:id])

    respond_to do |format|
      if @store_map.update_attributes(params[:store_map])
        format.html { redirect_to @store_map, notice: 'Store map was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @store_map.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /store_maps/1
  # DELETE /store_maps/1.json
  def destroy
    @store_map = StoreMap.find(params[:id])
    @store_map.destroy

    respond_to do |format|
      format.html { redirect_to store_maps_url }
      format.json { head :ok }
    end
  end
end
