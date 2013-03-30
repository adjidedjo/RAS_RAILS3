class StockController < ApplicationController
  def index
    @id_cabang = Cabang.get_id
    @get_stock = Stock.get_record(params[:date], current_user) unless params[:date].nil?
  end
  
  def update_kategori
    product = Merk.where(["id in (?)", params[:merk_id]]).each do |a|
      a.brand.map{|a| a.NamaBrand}
    end
    merk_product = Brand.where(:merk_id => product)
    @category = merk_product.map{|c| [c.NamaBrand,c.KodeBrand]}.insert(0)
    @category = Brand.all.map{|c| c.NamaBrand}.insert(0) if params[:merk_id] == "null"
  end
  
  def update_jenis_produk
    brand_product = BrandProduct.where(["kode_brand in (?)", params[:category_id]]).each do |brand_product|
      brand_product.product
    end.flatten
    @brand_product = brand_product.map{|c| [c.product.Namaroduk,c.product.KodeProduk]}.insert(0)
    @brand_product = Product.all.map{|c| c.Namaroduk}.insert(0) if params[:category_id] == "null"
  end
  
  def update_artikel
    artikel = Product.where(["KodeProduk in (?)", params[:artikel_id]]).each do |product|
      product.artikel.map{|a| a.Produk}
    end
    artikel_product = Artikel.where(:product_id => artikel)
    @artikel = artikel_product.map{|c| [c.Produk,c.KodeCollection]}.insert(0)
    @artikel = Artikel.all.map{|c| c.Produk}.insert(0) if params[:artikel_id] == "null"
  end
end