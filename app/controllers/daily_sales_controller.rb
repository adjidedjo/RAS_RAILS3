class DailySalesController < ApplicationController
  # GET /daily_sales
  # GET /daily_sales.json
  def index
    @daily_sales = current_user.cabang.nil? ? DailySale.all : DailySale.where(current_user.cabang)
    @brands = Merk.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @daily_sales }
    end
  end

  # GET /daily_sales/1
  # GET /daily_sales/1.json
  def show
    @daily_sale = DailySale.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @daily_sale }
    end
  end

  # GET /daily_sales/new
  # GET /daily_sales/new.json
  def new
    @daily_sale = DailySale.new
    @brands = Merk.all

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @daily_sale }
    end
  end

  # GET /daily_sales/1/edit
  def edit
    @daily_sale = DailySale.find(params[:id])
  end

  # POST /daily_sales
  # POST /daily_sales.json
  def create
    user = current_user.cabang.nil? ? 1 : current_user.cabang
    day = ["day" + Date.today.strftime('%d'), params[:total_salesman]]
    has_of_day = Hash[*day.flatten]
    params[:daily_sale].merge!(has_of_day)
    @daily_sale = DailySale.new(params[:daily_sale])
    @daily_sale.tipe = "Salesman"
    @daily_sale.cabang_id = user
    @daily_sale.bulan = Date.today.strftime('%m').to_i
    @daily_sale.tahun = Date.today.strftime('%Y')
    

    respond_to do |format|
      if @daily_sale.save
        format.html { redirect_to new_daily_sale_path, notice: 'Tracking Sales sudah terbuat.' }
        format.json { render json: new_daily_sale_path, status: :created, location: @daily_sale }
      else
        format.html { redirect_to new_daily_sale_path, alert: 'Tidak boleh ada yang kosong.' }
        format.json { render json: @daily_sale.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /daily_sales/1
  # PUT /daily_sales/1.json
  def update
    @daily_sale = DailySale.find(params[:id])

    respond_to do |format|
      if @daily_sale.update_attributes(params[:daily_sale])
        format.html { redirect_to @daily_sale, notice: 'Daily sale was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @daily_sale.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /daily_sales/1
  # DELETE /daily_sales/1.json
  def destroy
    @daily_sale = DailySale.find(params[:id])
    @daily_sale.destroy

    respond_to do |format|
      format.html { redirect_to daily_sales_url }
      format.json { head :ok }
    end
  end
end
