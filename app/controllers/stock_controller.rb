class StockController < ApplicationController
  def index
    @id_cabang = Cabang.get_id
    @get_merk = Merk.all
    unless params[:category_id].nil?
      @get_stock = Stock.check_stock(params[:date]).group("barang_id").order("id desc").get_stock_by_category(params[:category_id]) unless params[:date].nil?
    end
    @category =  Brand.all
  end
  
  def update_kategori
    product = Merk.where(["id in (?)", params[:merk_id]]).each do |a|
      a.brand.map{|a| a.NamaBrand}
    end
    merk_product = Brand.where(:merk_id => product)
    @category = merk_product.map{|c| [c.NamaBrand,c.KodeBrand]}.insert(0)
    @category = Brand.all.map{|c| c.NamaBrand}.insert(0) if params[:merk_id] == "null"
  end
end