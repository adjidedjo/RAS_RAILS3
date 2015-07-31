class RegionalsController < ApplicationController

  def show_history_product
    @history_product = PriceList.where("brand_id = ? and regional_id = ? and produk = ? and kain = ?",
      params[:bra], params[:reg], params[:pk], params[:kn]).group("produk, kain").order("created_at DESC")
    @item_version = []
    @history_product.each do |hp|
      @item_version << hp.versions.order("created_at ASC")
    end
  end

  def show_product
    @reg = params[:regional_id]
    @bra = params[:brand_id]
    @produk = PriceList.where("brand_id = ? and regional_id = ?", @bra, @reg).group("produk, kain, jenis")
  end

  def show_regional
    @regionals = Regional.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @regionals }
    end
  end

  def search_price_list
    @kategori = Product.all.map {|a| [a.Namaroduk, a.KodeProduk]}
    @artikel = Artikel.all.map {|a| [a.Produk, a.KodeCollection ]}
    @kain = Kain.all.map {|a| [a.NamaKain, a.KodeKain ]}
    if params[:branch_price_list].present? && params[:brand_price_list].present?
      merk_id = Merk.where(Merk: params[:brand_price_list]).first.id
      get_reg_id = RegionalBranch.find_by_cabang_id_and_brand_id(params[:branch_price_list], merk_id).regional.id
      @items = PriceList.find_kategori(params[:kategori_price_list]).find_tipe(params[:tipe_price_list]).find_kain(params[:kain_price_list]).where(regional_id: get_reg_id)
    end
  end

  def update_kode_barang
    item = PriceList.find_by_kode_barang_and_regional_id(params[:price_list]["kode_barang"], params[:price_list]["regional_id"])
    item.update_attributes!(params[:price_list].reject { |k,v| v.blank? })

    respond_to do |format|
      format.html { redirect_to show_price_list_regionals_path(kode_barang: params[:price_list]["kode_barang"], status: "e"), notice: "Berhasil di Update" }

    end
  end

  def show_price_list
    @item = PriceList.find_by_kode_barang(params[:kode_barang])
    @item_version = @item.versions.order("created_at DESC")
  end
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
    elsif params[:add] == 'other'
      redirect_to additional_lady_regionals_path(brand_id: params[:brand_id], regional_id: params[:regional_id], produk_ids: params[:produk_ids]) if params[:add] == 'other'
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
    @produk = PriceList.where("brand_id = ? and regional_id = ?", params[:brand_id], params[:regional_id]).group("produk, kain, jenis, panjang, lebar")
  end

  def additional_lady
    @artikel = PriceList.find(params[:produk_ids])
    @brand_id = params[:brand_id]
    @regional_id = params[:regional_id]
    child_chosen = []
    @artikel.each do |fpl|
      fpl.parent_items.each do |parent|
        child_chosen << PriceList.find(parent.child_item_id)
      end
    end
    @child_chosen = child_chosen
    @produk = if child_chosen.empty?
      PriceList.where("brand_id = ? and regional_id = ? and jenis not like ?",
        params[:brand_id], params[:regional_id], 'KM')
    else
      PriceList.where("brand_id = ? and regional_id = ? and id not in (?) and jenis not like ?",
        params[:brand_id], params[:regional_id], child_chosen.map(&:id), 'KM')
    end
  end

  def update_multiple_lady
    products = params[:products].gsub(/\W/, ',').split(',')
    @child = PriceList.find(params[:child_ids])
    @artikel = PriceList.find(products)
    @artikel.each do |artikel|
      artikel.update_attributes(additional_program: true)
      @child.each do |pl|
        artikel.parent_items.create(parent_item_id: artikel.id,
          child_item_id: pl.id,
          next_diskon4: params["price_list"]["discount_4"],
          next_cashback: params["price_list"]["cashback"],
          next_upgrade: params["price_list"]["upgrade"],
          program_starting_at: params["price_list"]["program_starting_at"].to_date)
      end
    end
    flash[:notice] = "Updated products!"
    redirect_to additional_lady_regionals_path(brand_id: params[:brand_id], regional_id: params[:regional_id], produk_ids: products)
  end

  def remove_multiple_lady
    goods = params[:artikel]
    child_goods = params[:produk].to_i
    goods.each do |gds|
      PriceList.find(gds).parent_items.find_by_child_item_id(child_goods).destroy
    end
    redirect_to additional_lady_regionals_path(brand_id: params[:brand_id], regional_id: params[:regional_id], produk_ids: params[:produk_ids])
  end
end
