class AccountingPriceListsController < ApplicationController
  include SalesReportsHelper

  def export_excel
    @export = LaporanCabang.search_by_branch(params[:branch_price_list]).brand(params[:brand]).month(params[:date][:month]).year(params[:year]) if params[:year].present?
    respond_to do |format|
      format.html
      format.xls
    end
  end

  def pilihan_brand
    redirect_to accounting_price_lists_path(:brand_price_list => params[:brand_price_list],
      :branch_price_list => params[:branch], :date => params[:date]['month'].to_i) if params[:brand_price_list].present?
  end

  # GET /accounting_price_lists
  # GET /accounting_price_lists.json
  def index
    unless params[:branch_price_list].blank? && params[:brand_price_list].blank?
      @accounting_price_lists = AccountingPriceList.search_by_month_and_year(params[:month_price_list].to_i, Date.today.year)
      .brand(brand(params[:brand_price_list])).search_by_branch(params[:branch_price_list]).where("checked = ?", false).order("nofaktur ASC")
      @accounting_price_list = AccountingPriceList.new
    end
  end

  # GET /accounting_price_lists/1
  # GET /accounting_price_lists/1.json
  def show
    @accounting_price_list = AccountingPriceList.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @accounting_price_list }
    end
  end

  # GET /accounting_price_lists/new
  # GET /accounting_price_lists/new.json
  def new
    @accounting_price_list = AccountingPriceList.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @accounting_price_list }
    end
  end

  # GET /accounting_price_lists/1/edit
  def edit
    @accounting_price_list = AccountingPriceList.find(params[:id])
  end

  # POST /accounting_price_lists
  # POST /accounting_price_lists.json
  def create
    @accounting_price_list = AccountingPriceList.new(params[:accounting_price_list])

    respond_to do |format|
      if @accounting_price_list.save
        format.html { redirect_to @accounting_price_list, notice: 'Accounting price list was successfully created.' }
        format.json { render json: @accounting_price_list, status: :created, location: @accounting_price_list }
      else
        format.html { render action: "new" }
        format.json { render json: @accounting_price_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /accounting_price_lists/1
  # PUT /accounting_price_lists/1.json
  def update
    @accounting_price_list = AccountingPriceList.find(params[:id])

    respond_to do |format|
      if @accounting_price_list.update_attributes(params[:accounting_price_list])
        format.html { redirect_to accounting_price_lists_path(:brand_price_list => params[:brand_price_list],
            :branch_price_list => params[:branch_price_list],
            :month_price_list => params[:month_price_list]), notice: 'Price list was successfully checked.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @accounting_price_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /accounting_price_lists/1
  # DELETE /accounting_price_lists/1.json
  def destroy
    @accounting_price_list = AccountingPriceList.find(params[:id])
    @accounting_price_list.destroy

    respond_to do |format|
      format.html { redirect_to accounting_price_lists_url }
      format.json { head :ok }
    end
  end

  def update_multiple
    @report = CheckedItemMaster.find(params[:report_ids])
    @report.each do |repsales|
      if params[:commit] == 'Checked as customer services'
        repsales.update_attributes!(:checked => true)
        repsales.update_attributes!(:customer_services => true)
      elsif params[:commit] == 'Set all as checked'
        repsales.update_attributes!(:checked => true)
      end
    end
    flash[:notice] = "Reports Checked"
    redirect_to accounting_price_lists_path(branch_price_list: params[:branch_price_list], brand_price_list: params[:brand_price_list], month_price_list: params[:month_price_list])
  end
end