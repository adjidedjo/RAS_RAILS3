class RegionalsController < ApplicationController
  # GET /regionals
  # GET /regionals.json
  def index
    @regionals = Regional.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @regionals }
    end
  end

  # GET /regionals/1
  # GET /regionals/1.json
  def show
    @regional = Regional.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @regional }
    end
  end

  # GET /regionals/new
  # GET /regionals/new.json
  def new
    @regional = Regional.new
    @branch = Cabang.get_id
    @brand = Merk.all

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @regional }
    end
  end

  # GET /regionals/1/edit
  def edit
    @regional = Regional.find(params[:id])
    @branch = Cabang.get_id
    @brand = Merk.all
  end

  # POST /regionals
  # POST /regionals.json
  def create
    @regional = Regional.new(params[:regional])
    @branch = Cabang.get_id
    @brand = Merk.all

    respond_to do |format|
      if @regional.save
        format.html { redirect_to @regional, notice: 'Regional was successfully created.' }
        format.json { render json: @regional, status: :created, location: @regional }
      else
        format.html { render action: "new" }
        format.json { render json: @regional.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /regionals/1
  # PUT /regionals/1.json
  def update
    @regional = Regional.find(params[:id])

    respond_to do |format|
      if @regional.update_attributes(params[:regional])
        format.html { redirect_to @regional, notice: 'Regional was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @regional.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /regionals/1
  # DELETE /regionals/1.json
  def destroy
    @regional = Regional.find(params[:id])
    cabang = Cabang.find_by_regional_id(@regional.id)
    cabang.update_attributes(:regional_id => nil)
    @regional.destroy

    respond_to do |format|
      format.html { redirect_to regionals_url }
      format.json { head :ok }
    end
  end
  
  def remove_cabang
    regional = Regional.find(params[:regional_id])
    @regional_branches = regional.regional_branches.where(cabang_id: params[:cabang_id])
    @regional_branches.first.destroy

    respond_to do |format|
      format.html { redirect_to regional, notice: 'Cabang was successfully removed from This Regional.' }
      format.json { head :ok }
    end
  end
  
  def list_cabang
    if params[:regional].present?
      @regional = Regional.find(params[:regional])
      cab = []
      RegionalBranch.where("brand_id = ?", @regional.brand_id).each do |a|
        cab << a.cabang_id
      end
      @cabang = cab.empty? ? Cabang.all : Cabang.where("id not in (?)", cab)
    end
  end
  
  def edit_multiple
    if params[:produk_ids].nil?
      redirect_to price_list_regionals_path(brand_id: params[:brand_id], 
        regional_id: params[:regional_id]), notice: 'Please select at lease one product.'
    else
      @artikel = FuturePriceList.find(params[:produk_ids])
      @brand_id = params[:brand_id]
      @regional_id = params[:regional_id]
    end
  end
  
  def update_multiple
    @artikels = FuturePriceList.find(params[:artikel_ids])
    @artikels.each do |artikel|
      artikel.update_attributes!(params[:future_price_list].reject { |k,v| v.blank? })
    end
    flash[:notice] = "Updated products!"
    redirect_to price_list_regionals_path(brand_id: params[:brand_id], regional_id: params[:regional_id])
  end
  
  def price_list
    @produk = FuturePriceList.where("brand_id = ? and regional_id = ?", params[:brand_id], params[:regional_id]).group("produk, jenis, panjang, lebar")
  end
end
