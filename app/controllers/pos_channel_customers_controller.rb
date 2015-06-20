class PosChannelCustomersController < ApplicationController
  def show
    @sale = Sale.find(params[:id])
    @get_spg = SalesPromotion.find(@sale.sales_promotion_id)
    @tipe_pembayaran = @sale.tipe_pembayaran.split(";")
  end

  def index
    @channel_customer = ChannelCustomer.all
  end

  def view_penjualan
    @channel_customer = ChannelCustomer.find(params[:cc_id])
    @sales = Sale.where(cancel_order: false, channel_customer_id: @channel_customer.id)

    respond_to do |format|
      format.html
      format.xls
    end
  end

  def view_selisih_stock
    @retur = ExhibitionStockItem.where(channel_customer_id: params[:cc_id]).group(:kode_barang, :no_sj)

    respond_to do |format|
      format.html
      format.xls
    end
  end

  def view_selisih_intransit
    @intransit = ExhibitionStockItem.where(channel_customer_id: params[:cc_id]).group(:kode_barang, :no_sj)

    respond_to do |format|
      format.html
      format.xls
    end
  end

  def view_stock
    @report_stock_in = StoreSalesAndStockHistory.where(channel_customer_id: params[:cc_id]).where("qty_in > ?", 0).group([:kode_barang, :no_sj])
    @report_stock_out = StoreSalesAndStockHistory.where(channel_customer_id: params[:cc_id], keterangan: "S")
    @report_stock_return = StoreSalesAndStockHistory.where(channel_customer_id: params[:cc_id], keterangan: "B")

    respond_to do |format|
      format.html
      format.xls
    end
  end
end
